#ifndef CLINICAL_FRAME_H
#define CLINICAL_FRAME_H

#include <Definitions.h>
#include <Electrode.h> 

class ClinicalFrame {
 public:
  typedef vector< Electrode >::iterator ElectrodeIterator;
  typedef vector< Electrode >::const_iterator ConstElectrodeIterator;

  ClinicalFrame( void ){ };
  ~ClinicalFrame( void ){ };
  
  void setCT( ImagePointerType ct) {ct_ = ct;}
  void addElectrode(Electrode e ) { headframe_.resize(headframe_.size() + 1, e);}

  ElectrodeIterator begin(){return headframe_.begin();}
  ElectrodeIterator end(){return headframe_.end();}

  ConstElectrodeIterator begin() const{return headframe_.begin();}
  ConstElectrodeIterator end() const{return headframe_.end();}
  
  void fromRefToCenter_(PhysicalPointType *physicalPoint);
  void fromCenterToRef_(PhysicalPointType *physicalPoint);
  void fromLPS2RAS_(PhysicalPointType *physicalPoint);

 private:
  
  string              name_; // [TODO]: is it better char*? usually it's 1/2 chars
  ulong               id_;
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
 
