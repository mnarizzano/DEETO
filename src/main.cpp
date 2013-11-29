#include <ClinicalFrame.h>
#include <Definitions.h>
#include <unistd.h>
#include <FCSVReader.h>
#include <FCSVWriter.h>
#include <VTKWriter.h>
#include <ContactConstructor.h>
#include <tclap/CmdLine.h>

/**
@mainpage DEETO
@author Massimo Narizzano Gabriele Arnulfo
*/

using namespace std;

int main (int argc, char **argv) {
	try{

		TCLAP::CmdLine cmd("DEETO",' ', "0.9");
		TCLAP::ValueArg<string> ctArg("c","ct","CT File IN",false,"","string",cmd);
		TCLAP::ValueArg<string> fiducialArg("f","fid","Fiducials File IN",false,"","string",cmd);
		TCLAP::ValueArg<string> file_outArg("o","out","fname OUT",false,"","string",cmd);
		TCLAP::ValueArg<string> out_type("t","o_type"," Output Type",false,"","string",cmd);

		cmd.parse( argc, argv );

		string fileCT  = ctArg.getValue();
		string filefcsv = fiducialArg.getValue();	
		string fileout  = file_outArg.getValue();


		cout<<fileCT<<" "<<filefcsv<<" "<<fileout<<endl;

		if( fileCT.length() == 0 ||
			filefcsv.length() == 0 ||
			fileout.length() == 0){
			cerr<<" Missing files use deeto -h to full help"<<endl;
			return EXIT_FAILURE;
		}

		// Clinical Frame containig all the information about the Frame and
		// related data
		ClinicalFrame* headFrame = new ClinicalFrame();

		// CT read and send to handframe as parameter
		ImageReaderType::Pointer ctReader = ImageReaderType::New();
		itk::NiftiImageIO::Pointer niftiImage = itk::NiftiImageIO::New();
		ctReader->SetImageIO(niftiImage);
		ctReader->SetFileName(string(fileCT));

		try{
			ctReader->Update();
		}catch( itk::ExceptionObject e){
			cerr<<e.what()<<endl;
			return EXIT_FAILURE;
		}

		ImageType::Pointer ctImage = ctReader->GetOutput();

		headFrame->setCT(ctImage);

		FCSVReader fcsvReader;
		fcsvReader.setFileInput(&filefcsv);
		fcsvReader.setClinicalFrame(headFrame);
		fcsvReader.update();
		headFrame = fcsvReader.getOutput();

		ContactConstructor contactConstructor(ctImage,headFrame);
		VoxelPointType voxelTarget;
		VoxelPointType voxelEntry;
		contactConstructor.update();  

		FCSVWriter writer1(fileout);
		VTKWriter writer2(fileout);

		writer1.setClinicalFrame(headFrame);
		writer2.setClinicalFrame(headFrame);
		try{
			writer1.update();
			writer2.update();
		}catch(itk::ExceptionObject e){
				cerr<<e.what()<<endl;
				return EXIT_FAILURE;
		}

		return EXIT_SUCCESS;

	}catch(TCLAP::ArgException &e){
			cerr << "error: " << e.error() << " for arg " << e.argId() << endl; 
			return EXIT_FAILURE;
	}

  
}
