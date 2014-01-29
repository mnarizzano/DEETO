#!/usr/bin/env python 

import itk 
import os
import sys
import tempfile
import subprocess


subjects = (10,)
#subjects = (10,11,12,15,17,19,22,23,24,31,34,36,38,39,40,41,42)
subjects_dir = '/biomix/home/staff/gabri/Dropbox/DEETO-DATA'

for subject in subjects:

	subject_dir='subject%02d' %subject
	reader = itk.ImageFileReader.IF3.New(FileName=os.path.join(subjects_dir,subject_dir,'r_oarm_seeg.nii.gz'))

	fcsv_in = os.path.join(subjects_dir,subject_dir,'seeg.fcsv')

	reader.Update()
	img = reader.GetOutput()
	 

	for value in xrange(100,2000,100):
		print "Doing step %d for subject%02d" % (value, subject)
		
		thresholdFilter = itk.ThresholdImageFilter.IF3.New()
		thresholdFilter.SetInput(img)
		thresholdFilter.SetLower(value)

		tmp_img_out = tempfile.NamedTemporaryFile(suffix='.nii.gz')

		thresholdFilter.Update()

		writer = itk.ImageFileWriter.IF3.New(FileName=tmp_img_out.name)
		writer.SetInput(thresholdFilter.GetOutput())
		writer.Update()

		out_file=os.path.join(subjects_dir, subject_dir,'data',('recon_thr_test_%d.fcsv' %value))

		with open(os.devnull, 'w') as devnull:
			subprocess.call(['deeto','-c',tmp_img_out.name,'-f',fcsv_in,'-o ',out_file,'-1'],stdout=devnull,stderr=devnull)

		del thresholdFilter
		tmp_img_out.close()
