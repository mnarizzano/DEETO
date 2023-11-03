# Testbench for DEETO

## Software Requirements

Strong dependecies:

MATLAB

| Packages                                |
|-----------------------------------------|                                          
| Curve Fitting Toolbox                   |                                 
| Image Processing Toolbox                |                          
| Optimization Toolbox                    |                      
| Signal Processing Toolbox               |                           
| Simulink 3D Animation                   |                       
| Statistics and Machine Learning Toolbox |          

or MATLAB online

## Structural Requirements

Folders must be structured: 
- root
    - dataset (NOT already provided)
    - scripts (already provided)
    - priv (already provided)
    - CreateCTs.mlx 
    - ct.nii.gz (already provided)

Where 
- root is the home of the project in Matlab 
- scripts contain a modified version of the [Scripts](https://osf.io/p3dx9/) from the paper [Blenkmann et al., 2022]
- dataset folder is the content of [ImplantationPoints_Depth.7z](https://osf.io/kdnzq) as the unpacked list of .png and .mat (only mat files are used) which still comes from the previously cited paper. Note: the folder has not been provided due to it's big size.
- priv is the copy of the priv folder of [iElectrodes](https://sourceforge.net/projects/ielectrodes/) latest version (the provided priv folder is from the one used for testing which is the version v1.020)
- CreateCTs.mlx is the main script used to generate artificial CTs 
- ct.nii.gz file provided as base ct whose file headers are used to create a modified copy

## Run 
Run CreateCTs.mlx into Matlab to create a zip in a "out" subfolder relative to the root of the project containing 
- CT .nii.gz (compressed) file which is the simulated 3D scan of the electrodes as a voxelized image (Volume field in 3DSlicer)
- .json file that contains for each electrode the real position of 
    - seedPoint: position of the electrode's head on the surface of the hull
    - targetPoint: 3D vector position of the last contact (tail)
    - intermediaryPoints: list of 3D vector positions of each intermediary point without the targetPoint
    - numContacts: number of in brain cilindric contacts 
    - iedist: distance between each contact
- brain .vtk which is the brain mesh used for this testbench (Model field in 3DSlicer)
- SEEG_fiducial .fcsv position of the markup points of every electrode (MarkupsFiducials field in 3DSlicer)

Every point has been multiplied by a [-1,-1,1] vector to align with the convention used by common tools used in the field (3DSlicer, etc)


CTs creation has been tested on Windows 10 and MATLAB online


## References
[Blenkmann et al., 2022. Modeling intracranial electrodes. A simulation platform for the evaluation of localization algorithms]
