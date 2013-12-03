#ifndef CLINICAL_FRAME_H
#define CLINICAL_FRAME_H

#include <Definitions.h>
#include <Electrode.h> 


/**
  ClinicalFrame class
  ===================

  this class is the central object that holds the information for reconstruction and saves the reconstructed data.
  It has a pointer to CT data which constitutes the reference space.
  */
class ClinicalFrame {
 public:
  typedef vector< Electrode >::iterator ElectrodeIterator;
  typedef vector< Electrode >::const_iterator ConstElectrodeIterator;

  ClinicalFrame( TCLAP::CmdLine* ){ };
  ClinicalFrame( void ){ };
  ~ClinicalFrame( void ){ };

  /** setter method for CT pointer */
  void setCT( ImagePointerType ct) {ct_ = ct;}

  /** add one Electrode to the vector< Electrode > once it has been reconstructed */
  void addElectrode(Electrode e ) { headframe_.resize(headframe_.size() + 1, e);}
	
  /** this function returns a pointer to HEAD in vector< Electrode > */
  ElectrodeIterator begin(){return headframe_.begin();}

  /** this function returns a pointer to TAIL in vector< Electrode > */
  ElectrodeIterator end(){return headframe_.end();}

  /** this function returns a const pointer to HEAD in vector< Electrode >*/
  ConstElectrodeIterator begin() const{return headframe_.begin();}

  /** this function returns a const pointer to TAIL in vector< Electrode >*/
  ConstElectrodeIterator end() const{return headframe_.end();}

  /** this function transform a physicalPoint from Ref to Centered space */
  void fromRefToCenter_(PhysicalPointType *physicalPoint);

  /** this function transform a physicalPoint from Centered to Reference space */
  void fromCenterToRef_(PhysicalPointType *physicalPoint);

  /** this function transform a physicalPoint from LPS to RAS space */
  void fromLPS2RAS_(PhysicalPointType *physicalPoint);

  /** this function returns true or false whether the vector< Electrode> is empty or not */
  bool isempty( void) const{ return headframe_.empty();}

  int getElectrodesNumber (void) const {return headframe_.size();}

 private:
  
  ImagePointerType    ct_;
  vector< Electrode > headframe_;

};

// Traslate the physicalPoint from a Center systems (typically fcsv is
// in centered) to a Ref system (typicalli CT)
void ClinicalFrame::fromCenterToRef_(PhysicalPointType *physicalPoint){
  VoxelPointType  voxelCenter;    // center in voxel coordinate 
  PhysicalPointType physicalCenter; // center in mm coordinate 
  ImageType::SizeType maxextent = ct_->GetLargestPossibleRegion().GetSize();  
  
  for(uint i=0;i < 3; voxelCenter[i] = maxextent[i++]/2);
  ct_->TransformIndexToPhysicalPoint(voxelCenter,physicalCenter);
  
  // PhysicalPoint is traslated with respect to the physical center
  (*physicalPoint)[0] -= physicalCenter[0];
  (*physicalPoint)[1] -= physicalCenter[1];
  (*physicalPoint)[2] += physicalCenter[2];
}
  
void ClinicalFrame::fromLPS2RAS_(PhysicalPointType *physicalPoint){
  // Transformed for the neurological space
  (*physicalPoint)[0] *= -1;
  (*physicalPoint)[1] *= -1;
}

// Traslate the physicalPoint from a Ref system (for example CT is
// in Ref) to a Center system (typicalli fcsv)
void ClinicalFrame::fromRefToCenter_(PhysicalPointType *physicalPoint){
  VoxelPointType  voxelCenter;    // center in voxel coordinate 
  PhysicalPointType physicalCenter; // center in mm coordinate 
  ImageType::SizeType maxextent = ct_->GetLargestPossibleRegion().GetSize();  
  
  for(uint i=0;i < 3; voxelCenter[i] = maxextent[i++]/2);
  ct_->TransformIndexToPhysicalPoint(voxelCenter,physicalCenter);
  
  // PhysicalPoint is translated with respect to the physical center
  (*physicalPoint)[0] += physicalCenter[0];
  (*physicalPoint)[1] += physicalCenter[1];
  (*physicalPoint)[2] -= physicalCenter[2];
}
#endif // CLINICAL_FRAME_H
