#!/usr/bin/perl

use lib '.';
use deeto;

$subjects_dir="/biomix/home/staff/gabri/Dropbox/DEETO-DATA";

@subjects= glob($subjects_dir."/subject*");
$subj_id = 1;

foreach(@subjects){
	
	deeto::prepare_analysis_files($subj_id);

	$subj_id += 1;
}


