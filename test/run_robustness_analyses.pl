#!/usr/bin/perl

use lib '.';
use deeto;

$subjects_dir="/biomix/home/staff/gabri/Dropbox/DEETO-DATA";

@subjects= glob($subjects_dir."/subject*");
#splice(@subjects,1,1);

foreach(@subjects){

	# I'll bet there's a more elegant way to do this
	# peaks the subj_id from folder name
	$subj_id = $_;
	$subj_id =~ s|(\D)||g;
	print $subj_id."\n";

	deeto::prepare_analysis_files($subj_id);
	deeto::run_single($subj_id);

#	deeto::run_robustness_test($subj_id);

}


