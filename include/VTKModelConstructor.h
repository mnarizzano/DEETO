#ifndef VTK_MODEL_CONSTRUCTOR_H
#define VTK_MODEL_CONSTRUCTOR_H

#include "Definitions.h"
#include <vtkAppendPolyData.h>
#include <vtkTubeFilter.h>
#include <vtkLineSource.h>
#include <vtkPolyData.h>
#include <vtkParametricSpline.h>
#include <vtkParametricFunctionSource.h>
#include <vtkSmartPointer.h>
#include <vtkPolyDataWriter.h>


/** VTKModelConstructor class

  This class constructs VTK 3D model based on reconstructed information
 
*/

class VTKModelConstructor{

	public:
		typedef vector< vtkSmartPointer<vtkPolyData> >::const_iterator ConstModelIterator;
		typedef vector< vtkSmartPointer<vtkPolyData> >::iterator ModelIterator;
		
		/**	@param cf holds the pointer to ClinicalFrame and to vector< Electrode >
		 @param c is a pointer to TCLAP::CmdLine class to set/get command line options*/ 
		VTKModelConstructor(const ClinicalFrame* cf, bool s){
			clinicalframe_ = cf; 
			singleOutputFile_ = s;
		}

		VTKModelConstructor(const ClinicalFrame* cf){clinicalframe_ = cf; singleOutputFile_= true;}
		~VTKModelConstructor( void ){};

		inline void setClinicalFrame(ClinicalFrame* cf){clinicalframe_= cf;}

		/** methods that returns a pointer to the HEAD of VTK model vector */
		inline ModelIterator begin( void ) {return vtkmodels_.begin();}

		/** methods that returns a pointer to the TAIL of VTK model vector */
		inline ModelIterator end( void ) {return vtkmodels_.end();}
	
		/** methods that check whether VTK model vector is empty */
		inline bool empty( void ){ return vtkmodels_.empty();}

		inline int size( void ) const { return vtkmodels_.size();}
		

		/** function that computes the euclidean distance between two points */
		/** core method that navigate the clinical frame, extracts the centroids for each contact, 
		  estimates the contact as well as the electrode axes, and builds the vtk model (cylinder + spline) based on reconstructed information
		  @return this function returns 0 or 1 upon failure or success, respectively
		 */
		int update();

		/** this function returns whether the user requested a single vtk file (ie all the electrodes together 
		  as output or multiple files (ie each electrode as separate vtk file) */
		bool getOutputMode( void )const{return singleOutputFile_;}

	protected:
		/** for each contact it estimates its position along the line that connectes contact1 and contact2 
		 ATM the function assumes that p1 and p2 are 3.5 mm apart, better estimation needs to be used 
		 in order to create more physically reliable models*/
		void estimateContactExtent_( double* , double* , vtkLineSource* );

		/** function that computes the euclidean distance between two points */
		double distance_(double* p1, double *p2);
	
	private:

		const ClinicalFrame* clinicalframe_; /** This variable holds the information about the implant */	
		vector< vtkSmartPointer<vtkPolyData> > vtkmodels_; /** write-out variable this is read by VTKWriter to save the data*/ 
		bool singleOutputFile_; /** boolean flag to choose between single or multiple (ie one for each electrode) files out */
};

int VTKModelConstructor::update(){
	//returns 0 on failure if clinicalframe is empty
	//returns 1 on success if models have been constructed

	// check wheter the clinicalframe is empty
	if(clinicalframe_->isempty()) return 0;

	// in order to be as accurate as possible
	// we should indeed fit all the points with a spline (which order?)
	// then take for each centroid the tangent to the spline as vtkLineSource
	// on the tangent line build the vtkTubeFilter as cylinder object

	ClinicalFrame::ConstElectrodeIterator const_elec_it;
	Electrode::ConstContactIterator const_contact_it;


	// for each electorde in clinical frame
	for(const_elec_it = clinicalframe_->begin(); const_elec_it != clinicalframe_->end(); const_elec_it++){

		vtkSmartPointer< vtkAppendPolyData > appendFilter = 
			vtkSmartPointer< vtkAppendPolyData >::New();

		// fit data with spline 
		vtkSmartPointer<vtkParametricSpline> spline = 
			vtkSmartPointer<vtkParametricSpline>::New();

		vtkSmartPointer<vtkParametricFunctionSource> cableSource =
			vtkSmartPointer< vtkParametricFunctionSource >::New();

		vtkSmartPointer<vtkPoints>	points = 
			vtkSmartPointer<vtkPoints>::New();

		vtkSmartPointer< vtkTubeFilter > cables = 
			vtkSmartPointer< vtkTubeFilter >::New();

		
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

		cableSource->SetParametricFunction(spline.GetPointer());

		cables->SetInputConnection(cableSource->GetOutputPort());
		cables->SetRadius(0.2);
		cables->SetNumberOfSides(10);
		cables->SetCapping(true);
		cables->Update();

		if(singleOutputFile_)
			vtkmodels_.push_back( cables->GetOutput() );

		else
			appendFilter->AddInput(cables->GetOutput());

		// TODO we can evaluate the spline at fixed t to get
		// the points that approximate each contact (how to deal with t=0 and t=1) 
		// once we get this spline->Evaluate(u1,p1); spline->Evaluate(u2,p2);
		// then line->SetPoint1(p1); line->SetPoint2(p2) and build the cylinders 
		// as we did in prev version

		ushort cont = 0;

		for(const_contact_it = const_elec_it->begin(); const_contact_it != const_elec_it->end(); const_contact_it++){

			vtkSmartPointer< vtkTubeFilter > cylinder = vtkSmartPointer< vtkTubeFilter >::New();
			vtkSmartPointer< vtkLineSource > line = vtkSmartPointer< vtkLineSource >::New();

			double p1[3],  p2[3];

			if( cont == const_elec_it->getContactNumber()-1){
				//is last contact 
				for( short i = 0; i<3; i++){
					p1[i] = (*(const_contact_it-1))[i];
					p2[i] = (*const_contact_it)[i];
				}
			}else{
				// all the other contacts
				for( short i = 0; i<3; i++){
					p2[i] = (*const_contact_it)[i];
					p1[i] = (*(const_contact_it+1))[i];
				}
			}
			

			estimateContactExtent_(p1,p2, line.GetPointer());

			cylinder->SetInputConnection(line->GetOutputPort());

			cylinder->SetRadius(0.8);
			cylinder->SetNumberOfSides(10);
			cylinder->SetCapping(true);
			cylinder->Update();

			if( singleOutputFile_){
				vtkmodels_.push_back( cylinder->GetOutput() );
			} else {
				appendFilter->AddInput(cylinder->GetOutput());
			}

			++cont;
			}		
			
			if( !singleOutputFile_){
				appendFilter->Update();
				vtkmodels_.push_back(appendFilter->GetOutput());
			}


		}

	
	return 1;


}
#endif //VTK_MODEL_CONSTRUCTOR_H

void VTKModelConstructor::estimateContactExtent_(double* p1, double* p2, vtkLineSource* line){
	// here we should solve parametric equation of the line to get the correct line extent 

	double p_beg[3], p_end[3];

	double dist = distance_(p1,p2);

	double t = 1.0 / dist;
				
	// estimate line extent
	for(ushort ii = 0 ; ii < 3 ; ii++){
		p_beg[ii] = p1[ii] + (1-t)*(p2[ii] - p1[ii]);
		p_end[ii] = p1[ii] + (1+t)*(p2[ii] - p1[ii]);
	}
	
	// fill line with estimated initial and final points
	line->SetPoint1(p_beg);
	line->SetPoint2(p_end);

}	


double VTKModelConstructor::distance_(double* p1, double *p2){

	return sqrt(pow(p1[0] - p2[0],2) + pow(p1[1] - p2[1],2) + pow(p1[2] - p2[2],2));
}

