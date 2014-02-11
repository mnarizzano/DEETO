#!/usr/bin/perl

use lib '.';
use deeto;

$subjects_dir="/biomix/home/staff/gabri/Dropbox/DEETO-DATA";

#@subjects=(2 .. 9, 11,13,15,17,19,20,21,24,25,26,28,31,34,35,37,38,39,40,41,42);
#@subjects=(34,35,37,38,39,40,41,42);
@subjects=(11,15,17,19,24,31,34,38,39,40,41,42);

foreach(@subjects){

	# I'll bet there's a more elegant way to do this
	# peaks the subj_id from folder name
	$subj_id = $_;
	$subj_id =~ s|(\D)||g;
	print $subj_id."\n";

	deeto::run_single($subj_id);

#	deeto::run_robustness_test($subj_id);

}
