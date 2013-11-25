#include <ClinicalFrame.h>
#include <Definitions.h>
#include <unistd.h>
#include <FCSVReader.h>
#include <FCSVWriter.h>
#include <ContactConstructor.h>
/**
@mainpage Università degli Studi di Genova BIO-STAR LAB Tesi
Magistrale Epilessia Focale @author Luca Paoletti
*/
using namespace std;

int main (int argc, char **argv) {

  // Temporary definition. Should be read form command line.
  char fileCT[]   = "/mnt/data/BIOLAB_DATA/gabri/img/tonelli/r_oarm_seeg_cleaned.nii.gz";
  char fileMRI[]  = "/home/";
  char filefcsv[] = "/mnt/data/BIOLAB_DATA/gabri/img/tonelli/SEEG.fcsv";
  char fileout[]  = "/home/";

  // Clinical Frame containig all the information about the Frame and
  // related data
  ClinicalFrame* headFrame = new ClinicalFrame();
  
  // CT read and send to handframe as parameter
  ImageReaderType::Pointer ctReader = ImageReaderType::New();
  itk::NiftiImageIO::Pointer niftiImage = itk::NiftiImageIO::New();
  ctReader->SetImageIO(niftiImage);
  ctReader->SetFileName(string(fileCT));
  ctReader->Update();
  ImageType::Pointer ctImage = ctReader->GetOutput();
  
  headFrame->setCT(ctImage);

  // mox TODO il reader; Il reader legge un file csv e per ogni
  // elettrodo crea un oggetto Electrode. Inoltre per ogni elettrodo
  // setta il targe e l'origine. Infine per ogni elettrodo calcola le
  // posizioni dei suoi contatti a seconda dell'algoritmo
  // implementato, in pratica gli algoritmi di Gabri/Luca.  Hint: per
  // la versione da mettere on-line implementerei solo il nuovo
  // algoritmo, ammesso che sia tanto bravo quanto quello vecchio e
  // sia robusto, altrimenti li mettiamo entrambi.
  FCSVReader fcsvReader;
  fcsvReader.setFileInput(filefcsv);
  fcsvReader.setClinicalFrame(headFrame);
  fcsvReader.update();
  headFrame = fcsvReader.getOutput();
  
  ContactConstructor contactConstructor(ctImage,headFrame);
  VoxelPointType voxelTarget;
  VoxelPointType voxelEntry;
  ClinicalFrame::ElectrodeIterator ptr = headFrame->begin();
  while(ptr != headFrame->end()) {
    PhysicalPointType target = ptr->getTarget() ;
    PhysicalPointType entry = ptr->getEntry();

    //cout << ptr->getName() << ": T("<< target[0] << "," << target[1] << "," << target[2] <<")" << "E("<< entry[0] << "," << entry[1] << "," << entry[2] <<")" << endl;
   
    contactConstructor.translatePhysicalPoint_(&target);
    contactConstructor.translatePhysicalPoint_(&entry);
    ctImage->TransformPhysicalPointToIndex(target,voxelTarget);
    ctImage->TransformPhysicalPointToIndex(entry,voxelEntry);    
    //    cout << ptr->getName() << ": T("<< voxelTarget[0] << "," << voxelTarget[1] << "," << voxelTarget[2] <<")" << "E("<< voxelEntry[0] << "," << voxelEntry[1] << "," << voxelEntry[2] <<")" << endl;
    ptr++;
  }

  contactConstructor.update();  

  // Electrode Reader
  //headFrame.setHeadFrame(fcsvReader->getOutput());
    
  // TODO: Mox: fare stampa per 3dslicer, tramite trasformazioni in un
  // vtk object?

  string fname_out = string("out.fcsv");
  FCSVWriter writer(&fname_out);
  writer.setClinicalFrame(headFrame);
  try{
	  writer.update();
  }catch(...){
	  cerr<<"macello"<<endl;
  }
  
}


