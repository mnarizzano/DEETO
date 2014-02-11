#!/usr/bin/env python 

import itk 
import os
import sys
import tempfile
import subprocess


subjects = (42,) 
#subjects = (11,15,17,19,24,31,34,38,39,40,41,42) 
subjects_dir = '/biomix/home/staff/gabri/Dropbox/DEETO-DATA'

for subject in subjects:

	subject_dir='subject%02d' %subject
	reader = itk.ImageFileReader.IF3.New(FileName=os.path.join(subjects_dir,subject_dir,'r_oarm_seeg.nii.gz'))
	
	segmFilter = itk.ConnectedThresholdImageFilter.IF3IF3.New()
	maskFilter = itk.MaskNegatedImageFilter.IF3ISS3IF3.New()
	castFilter = itk.CastImageFilter.IF3ISS3.New()
	thrFilter  = itk.ThresholdImageFilter.IF3.New()

	reader.Update()

	segmFilter.SetInput(reader.GetOutput())

	segmFilter.SetUpper(2600)
	segmFilter.SetLower(1100)
	segmFilter.SetSeed((279,228,183))

	castFilter.SetInput(segmFilter.GetOutput())
	castFilter.Update()

	maskFilter.SetInput1(reader.GetOutput())
	maskFilter.SetInput2(castFilter.GetOutput())

	maskFilter.Update()

	thrFilter.SetInput(maskFilter.GetOutput())
	thrFilter.ThresholdBelow(1600)

	writer = itk.ImageFileWriter.IF3.New(FileName=os.path.join(subjects_dir,subject_dir,'r_oarm_seeg_skull_strip.nii.gz'))
	writer.SetInput(thrFilter.GetOutput())
	
	writer.Update()
