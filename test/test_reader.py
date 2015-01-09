#!/usr/bin/env python 

import vtk
import os
import sys
import tempfile
import subprocess
import math
import numpy as np

from vtk.util.numpy_support import vtk_to_numpy as v2n

def MeshToVolume(Filename):
	reader = vtk.vtkPolyDataReader()
	pol2stenc = vtk.vtkPolyDataToImageStencil()
	imgstenc = vtk.vtkImageStencil()

	reader.SetFileName(os.path.join(subjects_dir,subject_dir,Filename))
	reader.Update()

	ref_mesh = reader.GetOutput()
	ref_volume = vtk.vtkImageData()

	# define output volume dimension
	spacing = (0.5,0.5,0.5)

	ref_volume.SetSpacing(spacing)

	bounds = ref_mesh.GetBounds()

	dim = [math.ceil(bounds[ii*2+1] - bounds[ii*2] / spacing[ii]) for ii in range(0,3)]
	origin = [bounds[ii*2] + spacing[ii] / 2 for ii in range(0,3)]
	extent = (0,dim[0] - 1,0,dim[1] -1 ,0,dim[2]-1)

	ref_volume.SetOrigin(origin)
	ref_volume.SetDimensions(dim)
	ref_volume.SetExtent(extent)

	ref_volume.SetScalarTypeToUnsignedChar()
	ref_volume.AllocateScalars()

	# Fill the image with white voxels
	for i in range(0,ref_volume.GetNumberOfPoints()):
		ref_volume.GetPointData().GetScalars().SetTuple1(i,255)

	print ref_volume.GetNumberOfPoints()

	pol2stenc.SetInput(ref_mesh)

	pol2stenc.SetOutputOrigin(origin)
	pol2stenc.SetOutputSpacing(spacing)
	pol2stenc.SetOutputWholeExtent(ref_volume.GetExtent())

	pol2stenc.Update()

	imgstenc.SetInput(ref_volume)
	imgstenc.SetStencil(pol2stenc.GetOutput())

	imgstenc.ReverseStencilOff()
	imgstenc.SetBackgroundValue(0)
	imgstenc.Update()
	tmp = imgstenc.GetOutput()

	writer = vtk.vtkImageWriter()
	writer.SetFileName('prova.nii.gz')
	writer.SetInput(ref_volume)
	writer.Update()

	out = v2n(tmp.GetPointData().GetScalars())

	return np.reshape(out, (dim[0],dim[1],dim[2]))

#subjects = (11,15,17,19,24,31,34,38,39,40,41,42) 
subjects = (01,)
subjects_dir = '/biomix/home/staff/gabri/data/DEETO-DATA'

for subject in subjects:
	
	#for each subject read the null_hypo vtk image file
	subject_dir='subject%02d' %subject
	Filename = os.path.join(subjects_dir,subject_dir,'recon-test.vtk')

	ref_volume = MeshToVolume(Filename)



#	
#	
#
#	for distance in range(1,15,2):
#		for sample in range(0,4):
#
#			Filename = 'recont_test_targetd%02d_c%02' %(distance,sample)
#			test_volume = MeshToVolume(Filename)

			



