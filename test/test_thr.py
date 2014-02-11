#!/usr/bin/env python 

import itk 
import os
import sys
import tempfile
import subprocess


subjects = (11,)#15,17,19,24,31,34,38,39,40,41,42) 
subjects_dir = '/biomix/home/staff/gabri/Dropbox/DEETO-DATA'

for subject in subjects:

	subject_dir='subject%02d' %subject
	reader = itk.ImageFileReader.IF3.New(FileName=os.path.join(subjects_dir,subject_dir,'r_oarm_seeg.nii.gz'))
	calc = itk.MinimumMaximumImageCalculator.IF3.New()
	
	fcsv_in = os.path.join(subjects_dir,subject_dir,'seeg.fcsv')

	reader.Update()
	img = reader.GetOutput()

	calc.SetImage( img )
	calc.Compute()

	maxValue = calc.GetMaximum()
	minValue = calc.GetMinimum()

	imgRange = maxValue - minValue
	maxRange = minValue + (imgRange * 0.95)
	minRange = minValue + (imgRange * 0.25)

	thr_values = [ round(minRange + a*(maxRange-minRange)*1.0/20.0) for a in range(0,21)]
	thr_string = [ b.replace('.','_') for b in [ "%.1f" % ((0.25 + a*0.035)*100) for a in range(0,21)]]
	
	for key,value in dict(zip(thr_string,thr_values)).iteritems():
		print "Doing step %s for subject%02d" % (key, subject)
		print value
		
		thresholdFilter = itk.ThresholdImageFilter.IF3.New()
		thresholdFilter.SetInput(img)
		thresholdFilter.SetLower(value)

		tmp_img_out = tempfile.NamedTemporaryFile(suffix='_%s.nii.gz' %key, delete=False)

		thresholdFilter.Update()

		writer = itk.ImageFileWriter.IF3.New(FileName=tmp_img_out.name)
		writer.SetInput(thresholdFilter.GetOutput())
		writer.Update()

		out_file=os.path.join(subjects_dir, subject_dir,'data',('recon_thr_test_raw_%s.fcsv' %key))

#		with open(os.devnull, 'w') as devnull:
#			subprocess.call(['deeto','-c',tmp_img_out.name,'-f',fcsv_in,'-o ',out_file,'-1','-r'],stdout=devnull,stderr=devnull)
#
#		del thresholdFilter
