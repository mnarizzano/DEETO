#!/usr/bin/perl

use lib '.';
use deeto;

$subjects_dir="/biomix/home/staff/gabri/Dropbox/DEETO-DATA";

@subjects= glob($subjects_dir."/subject*");

foreach(@subjects){

	# I'll bet there's a more elegant way to do this
	$subj_id = $_;
	$subj_id =~ s|(\D)||g;

	
	deeto::prepare_analysis_files($subj_id);

#	deeto::run_single($subj_id);

#	deeto::run_robustness_test($subj_id);

}


