#include <CmdParser.h>
#include <Definitions.h>
#include <ElectrodeTrajectoryConstructor.h>
//#include <unistd.h>
//#include <ContactConstructor.h>
//#include <itkOrientImageFilter.h>

/**
@mainpage DEETO - SLICER VERSION
@author Massimo Narizzano, Gabriele Arnulfo
*/

using namespace std;

int main (int argc, char **argv) {
  CmdParser cmd;
  
  
  string fileCT;
  if (cmd.parse(argc, argv) < 0){
    cerr << "Error in reading command line" << endl;
    cmd.printCmdLine(argv[0]);
    return EXIT_FAILURE;
  } else {
    //cmd.printData();
    // CT read and send to handframe as parameter
    ImageReaderType::Pointer ctReader = ImageReaderType::New();
    typedef itk::OrientImageFilter< ImageType, ImageType> orientFilter;
    orientFilter::Pointer filter = orientFilter::New();
    itk::NiftiImageIO::Pointer niftiImage = itk::NiftiImageIO::New();
    ctReader->SetImageIO(niftiImage);
    ctReader->SetFileName(string(cmd.getFileCT()));
		
    try{
      ctReader->Update();
    }catch( itk::ExceptionObject e){
      cerr<<e.what()<<endl;
      return EXIT_FAILURE;
    }
    
    // [MOX: A che serve questo?]
    filter->SetInput(ctReader->GetOutput());
    filter->UseImageDirectionOn();
    filter->SetDesiredCoordinateOrientation(itk::SpatialOrientation::ITK_COORDINATE_ORIENTATION_LAS);
    
    try{
      filter->Update();
    }catch( ... ){
      cerr<< " dammit "<<endl;
      return EXIT_FAILURE;
    }
    //[MOX fine] 

    ImageType::Pointer ctImage = ctReader->GetOutput();
    ElectrodeTrajectoryConstructor* trajectory = new ElectrodeTrajectoryConstructor(ctImage, cmd);
    
    int error = trajectory->update();

    //cpc.load(cmd);
    //vector< PhysicalPointType > contacts = cpc.compute();
    return EXIT_SUCCESS;
  }
}
