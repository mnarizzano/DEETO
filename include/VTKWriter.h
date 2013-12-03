#ifndef VTK_WRITER_H
#define VTK_WRITER_H

#include "Definitions.h"
#include "AbstractWriter.h"
#include "VTKModelConstructor.h"
#include <ostream>
#include <sstream>

/**
  VTKWriter class
*/

class VTKWriter: public AbstractWriter{

	public:
	    VTKWriter(string filename, TCLAP::CmdLine& c) :
			singleFileOut_("1","vtk-single-fout","Single output file for implant", c, false)
		{
			setFilename(filename);
			setExtension("vtk");
		}

		virtual ~VTKWriter( void ){ };


		/** implementation of virtual AbstractFileWriter::update 
		 This function navigate through vtkModelConstructor output and writes them down*/
		int update(); 

	private:

		/** this function constructs unique filename for multiple electrode write-out
		  it reads from clinicalFrame the electrode names and append labels to filenames.
		 */
		string getNextFilename_( string name);

		TCLAP::SwitchArg singleFileOut_; /** command line parametr to switch between single/multiple files write-out*/


};
#endif //VTK_WRITER


int VTKWriter::update() 
{
	checkFilename_();

	VTKModelConstructor vtkModels(getClinicalFrame(), singleFileOut_.getValue());

	VTKModelConstructor::ModelIterator model_it;

	assert(vtkModels.update());

	if( vtkModels.empty()) return 0;

	if(singleFileOut_.getValue()) {
		vtkSmartPointer<vtkAppendPolyData> appendPolyData = 
			vtkSmartPointer<vtkAppendPolyData>::New();

		vtkSmartPointer<vtkPolyDataWriter> writer =
			vtkSmartPointer<vtkPolyDataWriter>::New();

		writer->SetFileName(getFilename().c_str());


		for( model_it = vtkModels.begin();
				model_it != vtkModels.end();
				model_it++){

			appendPolyData->AddInput( (*model_it).GetPointer() );
		}

		writer->SetInputConnection(appendPolyData->GetOutputPort());
		writer->Write();
	} else {

		const ClinicalFrame* cf = getClinicalFrame();

		// something went wrong in VTKModel we have reconstructed 
		// a wrong amount of electrodes
		if( cf->getElectrodesNumber() != vtkModels.size())
			return 0;

		ClinicalFrame::ConstElectrodeIterator elect_it = cf->begin();
		for( model_it = vtkModels.begin();
				model_it != vtkModels.end();
				model_it++){

			vtkSmartPointer<vtkPolyDataWriter> writer =
				vtkSmartPointer<vtkPolyDataWriter>::New();

			writer->SetFileName(getNextFilename_( (elect_it++)->getName()).c_str());
			writer->SetInput((*model_it));
			writer->Write();
		}
	}

	return 1;
}

string VTKWriter::getNextFilename_( string name ){

	// get base filename
	string baseFilename = getFilename();

	stringstream tmp;

	// strip extension
	string tt = baseFilename.substr(0, baseFilename.find_last_of("."));
	
	// construct the unique filename
	tmp<<tt<<"_"<<name<<".vtk";

	// return lvalue
	return tmp.str();
}


