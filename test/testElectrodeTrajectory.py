import sys
from os import path, mkdir, listdir
import zipfile
import json
import pandas as pd
from numpy import array
import csv
import numpy.linalg as lg

sys.path.insert(0, path.join('/'.join(__file__.split('/')[:-2]),'src'))

from electrode_trajectory import ElectrodeTrajectoryConstructor

# Edit this with the filename without the file type
file_name = "2CloseElectrodes"
this_folder_path = '/'.join(__file__.split('/')[:-1])
if not path.isfile(path.join(this_folder_path,file_name+'.zip')):
    raise Exception("no zip file found")
testbench_path = path.join(this_folder_path,file_name)
if not path.isdir(testbench_path):
    mkdir(testbench_path)    

with zipfile.ZipFile(path.join(this_folder_path,file_name+'.zip'),"r") as zip_ref:
    zip_ref.extractall(testbench_path)

ct_file_path = path.join(testbench_path,[file for file in listdir(testbench_path) if file.endswith(".nii.gz")][0]) 

with open(path.join(testbench_path,[file for file in listdir(testbench_path) if file.endswith(".json")][0])) as json_file:
    electrodes = json.load(json_file)

with open(path.join(testbench_path,[file for file in listdir(testbench_path) if file.endswith(".fcsv")][0])) as csv_file:
    # read until column names
    for i,row in enumerate(csv.reader(csv_file)):
        if i==2: column_names = [row[0].split()[-1]]+row[1:]; break
    # read the rest of csv as fiducial points
    fiducial_points = pd.read_csv(csv_file,header=None,names=column_names)

assert len(fiducial_points) % 2 == 0, "fiducial points must be even (head and target for every electrode)"

trajectory_calculator = ElectrodeTrajectoryConstructor(ct_file_path)
for i in range(int(len(fiducial_points)/2)):
    # in python fiducial points must be inverted
    start_end_points = {"e":array(fiducial_points.iloc[2*i,1:4],dtype=float)*[-1,-1,1],"t":array(fiducial_points.iloc[2*i+1,1:4]*[-1,-1,1],dtype=float)}
    print(start_end_points)
    distances = [electrodes[i]['iedist']]*(electrodes[i]["numContacts"]-1)
    trajectory_points = trajectory_calculator.compute_electrode_trajectory(start_end_points,distances=distances)
    assert len(trajectory_points) == len(electrodes[i]['intermediatePoints']), "found different number of electrodes"
    avg_error = 0
    for traj_point,true_point in zip(reversed(trajectory_points),electrodes[i]['intermediatePoints']*array([-1,-1,1])):
        print("error:",round(lg.norm(traj_point-true_point),ndigits=8),"\t|\tdeeto:",traj_point,"\t|\tground truth:", true_point)
        avg_error += lg.norm(traj_point-true_point)
    print("average_error:",avg_error/len(trajectory_points))