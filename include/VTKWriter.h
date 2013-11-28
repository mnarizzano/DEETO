#ifndef VTK_WRITER_H
#define VTK_WRITER_H

#include "Definitions.h"
#include "AbstractWriter.h"
#include "VTKModelConstructor.h"
#include <ostream>

class VTKWriter: public AbstractWriter{

	public:
		/* Constructors */
	    VTKWriter(string filename){setFilename(filename);setExtension("vtk");}

		/* Destructor */
		virtual ~VTKWriter( void ){ };


		/* implementation of virtual AbstractFileWriter::update */
		void update() ;


};
#endif //VTK_WRITER


void VTKWriter::update() 
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

	for( model_it = vtkModels.begin();
			model_it != vtkModels.end();
			model_it++){

		appendPolyData->AddInput( (*model_it).GetPointer() );
	}

	writer->SetInputConnection(appendPolyData->GetOutputPort());
	writer->Write();
}

