#ifndef VTK_WRITER_H
#define VTK_WRITER_H

#include "Definitions.h"
#include "AbstractWriter.h"
#include "VTKModelConstructor.h"
#include <ostream>

class VTKWriter: public AbstractWriter{

	public:
		/* Constructors */
	    VTKWriter(string* filename){setFilename(filename);}
		VTKWriter(string* filename, VTKModelConstructor* vm){
			setFilename(filename);
			3dmodel_ = vm;
		}

		/* Destructor */
		virtual ~VTKWriter( void ){ };

		inline void setVTKModelConstructor( VTKModelConstructor* vm){3dmodel_ = vm;}

		/* implementation of virtual AbstractFileWriter::update */
		void update() const;

	private: 
		VTKModelConstructor* 3dmodel_;
};
#endif //VTK_WRITER


void VTKWriter::update() const
{
//
//		vtkSmartPointer<vtkPolyDataWriter> writer =
//			vtkSmartPointer<vtkPolyDataWriter>::New();
//		writer->SetFileName(getFilename()->c_str());
//
//		vtkSmartPointer<vtkAppendPolyData> appendPolyData = 
//			vtkSmartPointer<vtkAppendPolyData>::New();
//
//
//		writer->SetInputConnection(appendPolyData_->GetOutputPort());
//		try{
//			writer->Write();
//		}catch(...){ // will it throw exceptions?
//			cerr<<" Error in writing PolyData"<<endl;
//		}
}
#endif //VTK_WRITER_H
