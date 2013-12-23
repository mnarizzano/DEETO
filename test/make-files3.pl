#!/usr/bin/perl
#variabili da modificare all'occorrenza
$exe = "/home/mox/Desktop/Luca-Paoletti0Tesi2.3/Release8/bin/Release8Exe";
$fileanalisi = "/home/mox/Dropbox/TESI_BIO-STAR-LAB_2012/Analisi-Sperimentale/input_mm.txt";
$numMax_campioni = 5; #10
$init_distanza = 1.0; #1.0
$end_distanza = 10.0; # 10.0



# Prima leggo il File di configurazione
if ($#ARGV < 0)  {
    $conf = "default_configure.txt";
}else{
    $conf = $ARGV[0]; 
}  
printf("FILE DI CONFIGURAZIONE $conf $#ARGV \n");
 
open(CONFIG,"< $conf") or die $!;
@config = <CONFIG>;
close(CONFIG);

# Prima riga contiene il nome della CT
$file_ct=$config[0];
chomp($file_ct);
# Seconda riga contiene il nome del file fcsv
$file=$config[1];
chomp($file);
# La terza riga contiene l'output directory dove mettere i files
$outdir = $config[2];
chomp($outdir);

# La quarta riga contiene l'output directory per il risultato da
# mettere sull'input.txt da dare in input al file che calcola gli
# elettrodi
$outdir_result = $config[3];
chomp($outdir_result);

# La quinta riga contiene gli elettrodi da 
$file_row = $config[4];
while ($file_row =~/^([A-Z]\'*);(.+)*/){
    $file_row = $2;
    push(@elettrodi,$1);
    printf("$1\n");
}

open(FCSV,"< $file") or die $!;
@fcsv = <FCSV>;
close(FCSV);
## File di configurazione 
open(FANAL,"> $fileanalisi") or die $!;

### faccio girare i due algoritmi anche per il file originale.
printf(FANAL "$file_ct "); #file dove si trova la CT
printf(FANAL "$file "); #file di sample
printf(FANAL "0 "); #lut
$file_res = $outdir_result . "file-orig-algo0.res";
printf(FANAL "$file_res "); #file di risultato
printf(FANAL "0 \n"); #algoritmo	
printf(FANAL "$file_ct "); #file dove si trova la CT
printf(FANAL "$file "); #file di sample
printf(FANAL "0 "); #lut
$file_res = $outdir_result . "file-orig-algo1.res";
printf(FANAL "$file_res "); #file di risultato
printf(FANAL "1 \n"); #algoritmo	

for($distanza = $init_distanza; $distanza < $end_distanza; $distanza*=2) {
    for($campione = 0; $campione < $numMax_campioni; $campione++){
	$file_out = $outdir . "sample_d".$distanza . "_c".$campione.".fcsv";
	open(OUT,"> $file_out") or die $!;
	
	$i = 0;
	while (!($fcsv[$i] =~/^([A-Z]\'*),(-*[0-9]*\.*[0-9]*),(-*[0-9]*\.*[0-9]*),(-*[0-9]*\.*[0-9]*),/)){
	    printf(OUT "$fcsv[$i]");
	    $i++;
	    
	}
	
	for(; $i <= $#fcsv; $i+=1){
	    if($fcsv[$i] =~/^([A-Z]\'*),(-*[0-9]*\.*[0-9]*),(-*[0-9]*\.*[0-9]*),(-*[0-9]*\.*[0-9]*),([0-1]*),([0-1]*)/){
		$c = $1; # contatto
		$x1 = scalar($2);
		$y1 = scalar($3);
		$z1 = scalar($4);
		$t1 = scalar($5);
		$s1 = scalar($6);
		if(isIn($c,@elettrodi) == 1){
		    $j = $i + 1;
		    if($fcsv[$j] =~/^([A-Z]\'*),(-*[0-9]*\.*[0-9]*),(-*[0-9]*\.*[0-9]*),(-*[0-9]*\.*[0-9]*),([0-1]*),([0-1]*)/){
			$x2 = scalar($2);
			$y2 = scalar($3);
			$z2 = scalar($4);
			$t2 = scalar($5);
			$s2 = scalar($6);
			printNewTarget($c,$x1,$y1,$z1,$t1,$s1,$x2,$y2,$z2,$t2,$s2,$distanza);
			$i++;
		    }
		} else {
		    printf(OUT "$fcsv[$i]");
		}
	    } 
	}
	printf(FANAL "$file_ct "); #file dove si trova la CT
	printf(FANAL "$file_out "); #file di sample
	printf(FANAL "0 "); #lut
	$file_res = $outdir_result . "sample_d".$distanza . "_c".$campione."-algo0.res";
	printf(FANAL "$file_res "); #file di risultato
	printf(FANAL "0 \n"); #algoritmo	
	printf(FANAL "$file_ct "); #file dove si trova la CT
	printf(FANAL "$file_out "); #file di sample
	printf(FANAL "0 "); #lut
	$file_res = $outdir_result . "sample_d".$distanza . "_c".$campione."-algo1.res";
	printf(FANAL "$file_res "); #file di risultato
	printf(FANAL "1 \n"); #algoritmo	
    }
}
close(OUT);
exit(0);
#### Ancora main Qui calcolo gli errori medi per ogni campione
#### rispetto al file originale
@result = `$exe $fileanalisi`;

$algoritmo = 0;
for($algoritmo = 0; $algoritmo <= 1; $algoritmo++) {
    $file_errore = "errori_algo_". $algoritmo . ".txt";
    open (ERRORI, "> $file_errore") or die $!;
    $file_res = $outdir_result . "file-orig-algo".$algoritmo.".res";
    open(ORIG, "< $file_res") or die $!;
    @campioni_originali = <ORIG>;
    close(ORIG);
# Intestazione
    printf(ERRORI "elettrodo ");
    for($distanza = $init_distanza; $distanza < $end_distanza; $distanza*=2) {
	for($campione = 0; $campione < $numMax_campioni; $campione++){
	    printf(ERRORI "$distanza-$campione ");
	}
    }
    printf(ERRORI "\n");
    
    for($i = 1; $i <= $#campioni_originali; $i++){
	chomp($campioni_originali[$i]);
	#printf("$campioni_originali[$i]\n");
	if ($campioni_originali[$i] =~/^([A-Z]\'*[0-9]*);\s*(-*[0-9]*\.*[0-9]*);\s*(-*[0-9]*\.*[0-9]*);\s*(-*[0-9]*\.*[0-9]*)/){
	    $ele = $1;
	    $x = scalar($2);
	    $y = scalar($3);
	    $z = scalar($4);
	    if ($ele =~/([A-Z])\'([0-9]*)/){
		$ele1 = $1 . "\\'" . $2;
	    } else {
		$ele1 = $ele;
	    }
	    $ele1 = $ele1 . "\\;";
	    printf (ERRORI "$ele ");
	    for($distanza = $init_distanza; $distanza < $end_distanza; $distanza*=2) {
		for($campione = 0; $campione < $numMax_campioni; $campione++){
		    $file_res = $outdir_result . "sample_d".$distanza . "_c".$campione."-algo".$algoritmo.".res";
		    #printf("grep $ele1 $file_res`;\n");
		    @res = `grep $ele1 $file_res`;
		    #printf("@res\n");
		    if ($#res == -1) {
			printf(ERRORI "-1 ");
		    }elsif($#res > 0) {
			printf("ERRORE : ");
			printf("grep $ele1 $file_res`;\n");
		    }else{
			chomp (@res);
			if ($res[0] =~/^([A-Z]\'*[0-9]*);\s*(-*[0-9]*\.*[0-9]*);\s*(-*[0-9]*\.*[0-9]*);\s*(-*[0-9]*\.*[0-9]*)/){
			    $x1 = scalar($2);
			    $y1 = scalar($3);
			    $z1 = scalar($4);
			    $dist = sqrt(($x1-$x)**2 + ($y1-$y)**2 + ($z1-$z)**2);
			    printf(ERRORI "$dist ");
			}
		    }
		}
	    }
	    printf(ERRORI "\n");
	}
    }
    close(ERRORI);
}

sub isIn 
{
    my @list = @_;
    my $i = 1;
    $c = $list[0];
    while ($i <= $#list) {
	if ($c eq $list[$i]) { return 1;}
	$i++;
    }
    return 0;
}

sub printNewTarget
{
    my @punti = @_;
    my @newpunto;
    $contatto = $punti[0];
    $xa = $punti[1];
    $ya = $punti[2];
    $za = $punti[3];
    $ta = $punti[4];
    $sa = $punti[5];
    $xb = $punti[6];
    $yb = $punti[7];
    $zb = $punti[8];
    $tb = $punti[9];
    $sb = $punti[10];
    $R= $punti[11]; #RAGGIO DELLA SFERA

    #calcolo la distanza tra O e i due punti:
    $da = $xa**2 + $ya**2 + $za**2;
    $db = $xb**2 + $yb**2 + $zb**2;
    if($da > $db) { 
	$xt = $xb; 
	$yt = $yb;
        $zt = $zb;
	$tt = $tb;
	$st = $sb;
	$xe = $xa; 
	$ye = $ya;
        $ze = $za;	
	$te = $ta;
	$se = $sa;
    } else {
	$xt = $xa; 
	$yt = $ya;
        $zt = $za;
	$tt = $ta;
	$st = $sa;
	$xe = $xb; 
	$ye = $yb;
        $ze = $zb;	
	$te = $tb;
	$se = $sb;
    }
    printf("$contatto,($xt,$yt,$zt)");
    $x0 = $xt;
    $y0 = $yt;
    $z0 = $zt;
    $x1 = $xe;
    $y1 = $ye;
    $z1 = $ze;
    # P0 = (xt,yt,zt)
    # P1 = (xe,yt,zt)
    # tiro a caso due numeri per (l,m,n) e fisso il terzo di conseguenza.
    

    $a = int(rand()*1000)/100;
    $b = int(rand()*1000)/100;

    if (($xt - $xe) != 0) {
	# fisso m,n e l lo assegno di conseguenza. 
	$m = $a;
	$n = $b;
	$l = -(($yt-$ye)*$m + ($zt-$ze)*$n) / ($xt-$xe);
    } elsif (($yt - $ye) != 0) {
	# fisso l,n e m lo assegno di conseguenza. 
	$l = $a;
	$n = $b;
	$m = -(($xt-$xe)*$l + ($zt-$ze)*$n) / ($yt-$ye);
    } elsif (($zt - $ze) != 0) {
	# fisso l,m e n lo assegno di conseguenza. 
	$l = $a;
	$m = $b;
	$n = -(($xt-$xe)*$l + ($yt-$ye)*$m) / ($zt-$ze);
    }else {
	printf("Errore, il target giace su un piano extradimensionale!!!\n");
	exit(0);
    }
    $delta = sqrt($l**2 + $m**2 + $n**2);
    $pari = int(rand()*1000) % 2;
    if ($pari == 0) {
	$t = $R/$delta;
    }else {
	$t = -1*$R/$delta;
    }
    $xt += $l*$t;
    $yt += $m*$t;
    $zt += $n*$t;
    printf("($xt,$yt,$zt)\n");
    printf(OUT "$contatto,$xe,$ye,$ze,$te,$se\n");
    printf(OUT "$contatto,$xt,$yt,$zt,$tt,$st\n");

    ## CONTROLLO CHE il nuovo target sia sulla circonferenza in centro
    ## P0 e raggio R e che giaccia sul piano passante per P0 e
    ## ortogonale alla retta P0-P1

    $piano = ($x0 -$x1) * $xt + ($y0 -$y1) * $yt + ($z0 -$z1) * $zt;
    $piano -= (($x0 -$x1) * $x0 + ($y0 -$y1) * $y0 + ($z0 -$z1) * $z0); 
    if ($piano > 0.0000001) {
	printf("ERROR : il punto non appartiene al piano: $piano\n");
    }
    $sfera = ($xt -$x0)**2 + ($yt -$y0)**2 + ($zt -$z0)**2 - $R**2;
    if ($sfera > 0.0000001) {
	printf("ERROR : il punto non appartiene alla sfera: $sfera\n");
    }
}
