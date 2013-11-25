#ifndef VTK_MODEL_CONSTRUCTOR_H
#define VTK_MODEL_CONSTRUCTOR_H

#include "Definitions.h"
#include <vtkAppendPolyData.h>
#include <vtkTubeFilter.h>
#include <vtkLineSource.h>
#include <vtkParametricSpline.h>
#include <vtkParametricFunctionSource.h>
#include <vtkSmartPointer.h>
#include <vtkPolyDataWriter.h>
#include <ostream>

class VTKModelConstructor{
	public:
		VTKModelConstructor(ClinicalFrame* cf ){
			clinicalframe_ = cf;
		};
		~VTKModelConstructor( void ){};

		inline void setClinicalFrame(ClinicalFrame* cf){clinicalframe_= cf;}
		inline const ClinicalFrame* getClinicalFrame( void ) const{ 
			return clinicalframe_;}
		inline ClinicalFrame::ConstElectrodeIterator begin( void ) const{
			return clinicalframe_->begin();}
		inline ClinicalFrame::ConstElectrodeIterator end( void ) const{
			return clinicalframe_->end();}

		int update();

	protected:
		/* for each contact it estimates its position along the spline */
		void estimateContactExtent_( void );
	
	private:
		/* this holds the implant details*/
		ClinicalFrame* clinicalframe_;	
		vector<vtkPolyData> 3dmodels_;
};


int VTKModelConstructor::update(){
		
		// check wheter the clinicalframe is empty
		if(clinicalframe_->isempty()) return FALSE;

		// in order to be as accurate as possible
		// we should indeed fit all the points with a spline (which order?)
		// then take for each centroid the tangent to the spline as vtkLineSource
		// on the tangent line build the vtkTubeFilter as cylinder object
	
		ClinicalFrame::ConstElectrodeIterator const_elec_it;
		Electrode::ConstContactIterator const_contact_it;

		// for each electorde in clinical frame
		for(const_elec_it = begin(); const_elec_it != end(); const_elec_it++){

			// fit data with spline/line and get the electrode axis
			vtkSmartPointer<vtkParametricSpline> spline = 
				vtkSmartPointer<vtkParametricSpline>::New();

			vtkSmartPointer<vtkPoints>	points = 
				vtkSmartPointer<vtkPoints>::New();

			vtkSmartPointer<vtkParametricFunctionSource> splineTasselated = 
				vtkSmartPointer<vtkParametricFunctionSource>::New(); 
			
			
			for(const_contact_it = const_elec_it->begin();
					const_contact_it != const_elec_it->end();
					const_contact_it++){

				// add all the centroids to the spline
				double x = (*const_contact_it)[0];
				double y = (*const_contact_it)[1];
				double z = (*const_contact_it)[2];
				
				points->InsertNextPoint(x,y,z);
			}
			
			// fill the spline with points
			spline->SetPoints(points.GetPointer());

			for(const_contact_it = const_elec_it->begin();
					const_contact_it != const_elec_it->end();
					const_contact_it++){

				estimateContactExtent_((*const_contact_it), const_contact_it->Next());

			}		

			// the tasselated spline will mimic cables
			splineTasselated->SetParametricFunction(spline.GetPointer());
//
//			vtkTubeFilter cylinder = vtkTubeFilter::New();
//			cylinder.SetInput(line->GetOutput());
//
//			cylinder.SetRadius(electrodes.at(i)->GetDiameter()/2.0);
//			cylinder.SetNumberOfSides(10);
//			cylinder.SetCapping(true);
//			cylinder.Update();

			// this function call doesn't return anything 
			// vtk exceptions handling is almost absent (for design)
			// I just assume that IT WORKS
			splineTasselated->Update();

			// it might work if smartPointer prevent delete function call
			// indeed it still is poor designed IMHO
			3dmodels_.push_back(splineTasselated.GetOutput())

		}
		return TRUE;

}

#endif //VTK_MODEL_CONSTRUCTOR_H
