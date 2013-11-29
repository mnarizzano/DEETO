#include <ClinicalFrame.h>
#include <Definitions.h>
#include <unistd.h>
#include <FCSVReader.h>
#include <FCSVWriter.h>
#include <VTKWriter.h>
#include <ContactConstructor.h>
/**
@mainpage DEETO
@author Massimo Narizzano Gabriele Arnulfo
*/
using namespace std;

int main (int argc, char **argv) {

  // Temporary definition. Should be read form command line.
    // char fileCT[]   = "/home/mox/Desktop/Luca-Paoletti0Tesi2.3/Release8-mox/data/input-example-files/tonelli-test.nii.gz";
  // char fileCT[]   = "/home/mox/Dropbox/TESI_BIO-STAR-LAB_2012/data/Tonelli/tonelli/test.nii.gz";
  char fileCT[]   = "/home/mox/Dropbox/GABRI/segm_elec_tool/data/s1/r_oarm_seeg_cleaned.nii.gz";
  char fileMRI[]  = "/home/";
  // char filefcsv[] = "/home/mox/Desktop/Luca-Paoletti0Tesi2.3/Release8-mox/data/input-example-files/tonelli-SEEG2.fcsv";
  // char filefcsv[] = "/home/mox/Dropbox/TESI_BIO-STAR-LAB_2012/data/Tonelli/tonelli/SEEG-2.fcsv";
  // char filefcsv[] = "/home/mox/Dropbox/TESI_BIO-STAR-LAB_2012/data/Marchesi/marchesi_seeg.fcsv";
  // char filefcsv[] = "/home/mox/Desktop/Luca-Paoletti0Tesi2.3/segm_elec_tool/v0.0/data/input-example-files/marchesi_seeg-corretti.fcsv";
  // char filefcsv[] = "/home/mox/Desktop/Luca-Paoletti0Tesi2.3/segm_elec_tool/v0.0/data/input-example-files/marchesi_seeg-non-corretti.fcsv";
  char filefcsv[] = "/home/mox/Dropbox/GABRI/segm_elec_tool/data/s1/SEEG.fcsv";

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
  // setta il target e l'origine. Infine per ogni elettrodo calcola le
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
  contactConstructor.update();  
  string fname_out = string("out.fcsv");
  FCSVWriter writer1(fname_out);
  VTKWriter writer2(fname_out);
  
  writer1.setClinicalFrame(headFrame);
  writer2.setClinicalFrame(headFrame);
  try{
	  writer1.update();
	  writer2.update();
  }catch(...){
    cerr<<"macello"<<endl;
  }
  
}


