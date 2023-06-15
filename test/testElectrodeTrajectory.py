import sys
from os import path, mkdir, listdir
import zipfile
import json


sys.path.insert(0, path.join('/'.join(__file__.split('/')[:-2]),'src'))

from electrode_trajectory import ElectrodeTrajectoryConstructor


file_name = "2CloseElectrodes"
this_folder_path = '/'.join(__file__.split('/')[:-1])
testbench_path = path.join(this_folder_path,file_name)
if not path.isdir(testbench_path):
    mkdir(testbench_path)    

with zipfile.ZipFile(path.join(this_folder_path,file_name+'.zip'),"r") as zip_ref:
    zip_ref.extractall(testbench_path)

ct_file_path = path.join(testbench_path,[file for file in listdir(testbench_path) if file.endswith(".nii.gz")][0]) 

trajectory_calculator = ElectrodeTrajectoryConstructor(ct_file_path)

with open(path.join(testbench_path,[file for file in listdir(testbench_path) if file.endswith(".json")][0])) as json_file:
    electrodes = json.load(json_file)

# TODO Coordinate sembrano invertite sui due assi (-1,-1,1) perchè gli intermediary points invertiti e convertiti PhysToIndx sono luminosi, quelli non invertiti non sono luminosi
# Riguardare la CT_base lato matlab come mappa voxel -> spazio e rimapparle indietro
# Forse c'è un errore nello script matlab nella conversione da spazio a pixel quando faccio la media dei punti (controlla di fare prima la divisione coi float e poi la conversione ad int)
exit(1)
trajectory_calculator.compute_electrode_trajectory()