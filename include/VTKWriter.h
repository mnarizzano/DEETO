#ifndef VTK_WRITER
#define VTK_WRITER

#include "Definitions.h"
#include "AbstractWriter.h"
#include <vtkAppendPolyData.h>
#include <vtkTubeFilter.h>
#include <vtkLineSource.h>
#include <ostream>

class VTKWriter: public AbstractWriter{

	public:
	    VTKWriter(string* filename){setFilename(filename);}

		virtual ~VTKWriter( void ){ };

		bool update() const;
};
#endif //VTK_WRITER


void VTKWriter::update() const
{
		// in order to be as accurate as possible
		// we should indeed fit all the points with a spline (which order?)
		// then take for each centroid the tangent to the spline as vtkLineSource
		// on the tangent line build the vtkTubeFilter as cylinder object
		vtkAppendPolyData appendFilter; 
		vtkPolyDataWriter writer; 

		ClinicalFrame::ConstElectrodeIterator const_elec_it;
		// for each electorde in clinical frame
		
		for(const_elec_it = begin(); const_elec_it != end(); const_elec_it++){

			vtkTubeFilter cylinder = vtkTubeFilter::New();
			cylinder.SetInput(line->GetOutput());

			cylinder.SetRadius(electrodes.at(i)->GetDiameter()/2.0);
			cylinder.SetNumberOfSides(10);
			cylinder.SetCapping(true);
			cylinder.Update();

			appendFilter.AddInputConnection(cylinder->GetOutputPort());	
		}
		writer.SetInput(appendFilter->GetOutput());

		
		assert(writer.Write());
}
