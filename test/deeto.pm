#!/usr/bin/perl
package deeto;

use Exporter;

our @ISA=qw( Exporter );
our @EXPORT_OK=qw(prepare_analysis_file);

our $subjects_dir="/biomix/home/staff/gabri/Dropbox/DEETO-DATA";

our $file_ct;
our $file_fcsv;
our $outdir;


sub read_conf_file{

	$subject_dir=$subjects_dir."/subject".sprintf("%02s",@_);
	$conf=$subject_dir."/test.conf";

	printf("Doing Analyses on subject %d\n\t config file $conf\n",@_);
	 
	open(CONFIG,"< $conf") or die $!;
	@config = <CONFIG>;
	close(CONFIG);

	# Prima riga contiene il nome della CT
	$file_ct=$subject_dir.'/'.$config[0];
	chomp($file_ct);
	# Seconda riga contiene il nome del file fcsv
	$file_fcsv=$subject_dir.'/'.$config[1];
	chomp($file_fcsv);
	# La terza riga contiene l'output directory dove mettere i files
	$outdir = $subject_dir.'/'.$config[2];
	chomp($outdir);

	printf("\t\t%s\n\t\t%s\n\t\t%s\n",$file_ct,$file_fcsv,$outdir);
}

sub prepare_analysis_files{
	#variabili da modificare all'occorrenza

	$numMax_campioni = 5; #10
	$init_distanza = 1.0; #1.0
	$end_distanza = 16.0; # 10.0

	if (scalar(@_) < 0)  {
		$subj = 1;
	}else{
		$subj = @_; 
	} 
	 read_conf_file($subj);

	open(FCSV,"< $file_fcsv") or die $!;
	@fcsv = <FCSV>;
	close(FCSV);

	for($distanza = $init_distanza; $distanza < $end_distanza; $distanza*=2) {
	  for($campione = 0; $campione < $numMax_campioni; $campione++){
				$file_out = $outdir . "sample_d".$distanza . "_c".$campione.".fcsv";
				open(OUT,"> $file_out") or die $!;
		
				$i = 0;
				## stampa header del file fcsv 
				while (!($fcsv[$i] =~/^([A-Z]\'*),(-*[0-9]*\.*[0-9]*),(-*[0-9]*\.*[0-9]*),(-*[0-9]*\.*[0-9]*),/)){
						printf(OUT "$fcsv[$i]");
						$i++;
						
				}
				
				# genera nuovi punti target per ogni elettrodo nel file fcsv originale
				for(; $i <= $#fcsv; $i+=1){
						if($fcsv[$i] =~/^([A-Z]\'*),(-*[0-9]*\.*[0-9]*),(-*[0-9]*\.*[0-9]*),(-*[0-9]*\.*[0-9]*),([0-1]*),([0-1]*)/){
							$c = $1; # contatto
							$x1 = scalar($2);
							$y1 = scalar($3);
							$z1 = scalar($4);	
							$t1 = scalar($5);
							$s1 = scalar($6);
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
						} 
				}
			}
	}
	close(OUT);
	exit(0);
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
    $x0 = $xt;
    $y0 = $yt;
    $z0 = $zt;
    $x1 = $xe;
    $y1 = $ye;
    $z1 = $ze;
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

	$xt = sprintf("%.4f",$xt);
	$yt = sprintf("%.4f",$yt);
	$zt = sprintf("%.4f",$zt);

    printf(OUT "$contatto,$xe,$ye,$ze,$te,$se\n");
    printf(OUT "$contatto,$xt,$yt,$zt,$tt,$st\n");

}

sub run_single{
	#this case is quite simple
	`deeto -c $file_ct -f $file_fcsv -o ciccio.fcsv -1 2> /dev/null`; 
}

sub run_robustness_test{
	# this is a bit more complicated 

	@files_in=glob($outdir.'/sample*');

	foreach(@files_in){
		`deeto -c $file_ct -f $files_in -o ciccio.fcsv -1 2> /dev/null`; 	
	}

}

1;
