#ifndef VTK_WRITER_H
#define VTK_WRITER_H

#include "Definitions.h"
#include "AbstractWriter.h"
#include "VTKModelConstructor.h"
#include <ostream>

/**
  VTKWriter class
*/

class VTKWriter: public AbstractWriter{

	public:
		/** VTKWriter(string filename)
		  @param filename
		 */
	    VTKWriter(string filename){setFilename(filename);setExtension("vtk");}

		/** ~VTKWriter */
		virtual ~VTKWriter( void ){ };


		/** implementation of virtual AbstractFileWriter::update */
		int update() ;


};
#endif //VTK_WRITER


int VTKWriter::update() 
{
	checkFilename_();

	VTKModelConstructor vtkModels(getClinicalFrame());

	vtkSmartPointer<vtkPolyDataWriter> writer =
		vtkSmartPointer<vtkPolyDataWriter>::New();

	writer->SetFileName(getFilename().c_str());

	vtkSmartPointer<vtkAppendPolyData> appendPolyData = 
		vtkSmartPointer<vtkAppendPolyData>::New();
	
	VTKModelConstructor::ModelIterator model_it;

	assert(vtkModels.update());

	if( vtkModels.empty()) return 0;

	for( model_it = vtkModels.begin();
			model_it != vtkModels.end();
			model_it++){

		appendPolyData->AddInput( (*model_it).GetPointer() );
	}

	writer->SetInputConnection(appendPolyData->GetOutputPort());
	writer->Write();

	return 1;
}

