//TODO : 
//  - Cambiare nomi "translatatePhysicalPoint_" in "fromCenteredToUncentered" 
//  - Scrivere la descrizione dell'algoritmo di update per doxygen
//  - Fattorizzare meglio l'algoritmo di update.
//  - Code Refactoring per usare solo un tipo di coordinate
//    (centered/uncentered). al momento sono leggermente mischiati.
//  - Prendere anche il contatto che potrebbe essere vicinissimo
//    all'entry point.
#ifndef CONTACT_CONSTRUCTOR_H
#define CONTACT_CONSTRUCTOR_H

#include "Definitions.h"
#include "Electrode.h"
#include "ClinicalFrame.h"


class ContactConstructor {

 public:
  ContactConstructor(  ImageType::Pointer ctImage, ClinicalFrame* headFrame) {
    ctImage_   = ctImage;
    headFrame_ = headFrame;
  }
  ~ContactConstructor(){}
  
  void update( void );
  
 private:
  ImageType::Pointer ctImage_;
  ClinicalFrame*     headFrame_;


  void translatePhysicalPoint_(PhysicalPointType *physicalPoint);
  void undoTranslatePhysicalPoint_(PhysicalPointType *physicalPoint);
  RegionType retriveRegionAroundContact_(VoxelPointType index, int regionDim);
  void getNextContact_(PhysicalPointType* contact,PhysicalPointType contact1,PhysicalPointType contact2, double distance);
  void printContact_(string name,int  number,PhysicalPointType point);
  void computeFirstContact_(PhysicalPointType* contact,PhysicalPointType contact1,PhysicalPointType contact2, double distance);
  double getValue_(PhysicalPointType point);
  void computeNewEntry_(PhysicalPointType* contact, PhysicalPointType entry, PhysicalPointType target);

};

/*!
  This function takes a set of Electrodes where only target and entrypoint are setted 
  /*/
void ContactConstructor::update( void ){
  typedef itk::RegionOfInterestImageFilter<ImageType,ImageType> FilterType;
  typename FilterType::Pointer filter = FilterType::New();
  typename CalculatorType::Pointer calculator = CalculatorType::New();
  ClinicalFrame::ElectrodeIterator electrodeItr = headFrame_->begin();
  double dist = 0.0;
  while(electrodeItr != headFrame_->end()) {
    PhysicalPointType contact1 = electrodeItr->getTarget(); // set the second contact to the entry point
    PhysicalPointType contact2 = electrodeItr->getEntry(); // set the first contact to the entry point
    PhysicalPointType entryPoint = electrodeItr->getEntry(); // set the first contact to the entry point
    if (getValue_(entryPoint) == 0) 
      computeNewEntry_(&contact2, entryPoint, contact1); // If the point is into the void ....
    PhysicalPointType nextContactA,nextContactB;
    VoxelPointType    voxelNextContact;
    double distanceTargetEntry = contact1.EuclideanDistanceTo(entryPoint);
    double distanceEntryNextContact = 0.0;

    filter->SetInput(ctImage_);
    computeFirstContact_(&nextContactA,contact1,contact2,3.5);
    double incrementalDistance = 1.0;
    uint contactNum = 0;
    do {
      unsigned int k = 0;
      translatePhysicalPoint_(&nextContactA);
      do {
	nextContactB = nextContactA;
	ctImage_->TransformPhysicalPointToIndex(nextContactA,voxelNextContact);
	filter->SetRegionOfInterest(retriveRegionAroundContact_(voxelNextContact,3));
	calculator->SetImage(filter->GetOutput());
	
	try {
	  filter->Update();
	  calculator->Compute();
	  nextContactA[0] = calculator->GetCenterOfGravity()[0];
	  nextContactA[1] = calculator->GetCenterOfGravity()[1];
	  nextContactA[2] = calculator->GetCenterOfGravity()[2];
	} catch (itk::ExceptionObject &ex) {
	  cerr<<"Error : " << electrodeItr->getName() << " " << contactNum <<__LINE__<<ex.what()<<endl;
	}
	k++;  
	undoTranslatePhysicalPoint_(&nextContactA);
	dist = contact2.EuclideanDistanceTo(nextContactA);
	translatePhysicalPoint_(&nextContactA);	
      }while ((nextContactA != nextContactB) && (k < 10) && (dist <= 3.5) && (dist >= 2.5));
      undoTranslatePhysicalPoint_(&nextContactA);
      if (getValue_(nextContactA) > 0) {
	electrodeItr->addContact(nextContactA);
	printContact_(electrodeItr->getName(),contactNum,nextContactA);
	contact1 = contact2;
	contact2 = nextContactA;
	getNextContact_(&nextContactA,contact1,contact2,3.5);  
    	incrementalDistance = 1.0;
	contactNum++;
      } else {
	getNextContact_(&nextContactA,contact1,contact2,3.5+incrementalDistance);
	incrementalDistance += 1.0;
      }
      distanceEntryNextContact = entryPoint.EuclideanDistanceTo(nextContactA);
      undoTranslatePhysicalPoint_(&entryPoint);
      translatePhysicalPoint_(&entryPoint);
    } while (distanceEntryNextContact < (distanceTargetEntry+1.5)); // TODO: 1.5 e' un numero a caso per evitare che salti l'ultimo dei contatti.
    electrodeItr++;
  }
}

// return the first "contact" that occurs on the line contact1 - contact2. The distance between contact2 and contact should be distance.
void ContactConstructor::computeFirstContact_(PhysicalPointType* contact, PhysicalPointType contact1, PhysicalPointType contact2,double distance){
  double distancec1_c2 = 0;
  for (uint i = 0; i < 3; i++) distancec1_c2 += pow((contact1[i]-contact2[i]),2);
  distancec1_c2 = sqrt(distancec1_c2);
  for (uint i = 0; i < 3; i++) (*contact)[i] = contact2[i]+(contact1[i] - contact2[i])*distance/distancec1_c2;
}

// return a new "contact" that occurs on the line contact1 - contact2. The distance between contact2 and contact should be distance.
void ContactConstructor::getNextContact_(PhysicalPointType* contact, PhysicalPointType contact1, PhysicalPointType contact2, double distance) {
  double distancec1_c2 = 0;
  for (uint i = 0; i < 3; i++) distancec1_c2 += pow((contact1[i]-contact2[i]),2);
  distancec1_c2 = sqrt(distancec1_c2);
  for (uint i = 0; i < 3; i++) (*contact)[i] = contact2[i]-(contact1[i] - contact2[i])*distance/distancec1_c2;
}

void ContactConstructor::translatePhysicalPoint_(PhysicalPointType* physicalPoint) {
  VoxelPointType  voxelCenter;    // center in voxel coordinate 
  PhysicalPointType physicalCenter; // center in mm coordinate 
  ImageType::SizeType maxextent = ctImage_->GetLargestPossibleRegion().GetSize();  
  
  for(uint i=0;i < 3; voxelCenter[i] = maxextent[i++]/2);
  ctImage_->TransformIndexToPhysicalPoint(voxelCenter,physicalCenter);
  
  // PhysicalPoint is translated with respect to the physical center
  (*physicalPoint)[0] -= physicalCenter[0];
  (*physicalPoint)[1] -= physicalCenter[1];
  (*physicalPoint)[2] += physicalCenter[2];

  // Transformed for the neurological space
  (*physicalPoint)[0] *= -1;
  (*physicalPoint)[1] *= -1;
}

void ContactConstructor::undoTranslatePhysicalPoint_(PhysicalPointType* physicalPoint) {
  VoxelPointType  voxelCenter;    // center in voxel coordinate 
  PhysicalPointType physicalCenter; // center in mm coordinate 
  ImageType::SizeType maxextent = ctImage_->GetLargestPossibleRegion().GetSize();  
  
  for(uint i=0;i < 3; voxelCenter[i] = maxextent[i++]/2);
  ctImage_->TransformIndexToPhysicalPoint(voxelCenter,physicalCenter);
  // Transformed for the neurological space
  (*physicalPoint)[0] *= -1;
  (*physicalPoint)[1] *= -1;
  
  // PhysicalPoint is translated with respect to the physical center
  (*physicalPoint)[0] += physicalCenter[0];
  (*physicalPoint)[1] += physicalCenter[1];
  (*physicalPoint)[2] -= physicalCenter[2];
}


RegionType ContactConstructor::retriveRegionAroundContact_(VoxelPointType index, int regionDim) {
  typename ImageType::SizeType size;
  typename ImageType::RegionType region;
  SpacingType spacing = ctImage_->GetSpacing();
   
  for(unsigned int i=0;i<3;i++) {
    size[i]     = 2*((long int)(ceil(spacing[i] * regionDim)+1)); //luca: da considerare la dimensione dell'elettrodo? non tutti e tre cosi grossi
    index[i]   -= (long int)(ceil(spacing[i] * regionDim));
  }
  size[2]=(long int)ceil(size[1]-1); // ???? why ????
  region.SetSize(size);
  region.SetIndex(index);
  return region;
}

void ContactConstructor::printContact_(string name,int number,PhysicalPointType point) {
  cout << name << number<<","<< point[0] << "," << point[1] << "," << point[2] <<",1,1" <<endl;  
}

double ContactConstructor::getValue_(PhysicalPointType point) {
  PhysicalPointType physicalPoint = point;
  VoxelPointType    voxelPoint;
  translatePhysicalPoint_(&physicalPoint);
  ctImage_->TransformPhysicalPointToIndex(physicalPoint,voxelPoint);
  return ctImage_->GetPixel(voxelPoint);
}


// It tries to find an entry point that does not have null value :
// 1) First in an incremental region around the entry point if looks for a voxel that has value != 0.
// 2) From this point it looks for the point having maximal momentum (p)
// 3) Then the new entry is the projection of the entry point on the line from p to target.
//    (i.e. the intersection betwen line p-target and the line passing for the entry and ortogonal to the line p-target  
void ContactConstructor::computeNewEntry_(PhysicalPointType* contact, PhysicalPointType entry, PhysicalPointType target){
  int incrementalDistance = 3;
  PhysicalPointType  physicalEntry = entry;
  VoxelPointType     voxelEntry;
  PhysicalPointType  pippo;

  typename ImageType::RegionType region;
  translatePhysicalPoint_(&physicalEntry);
  ctImage_->TransformPhysicalPointToIndex(physicalEntry,voxelEntry);

  do{
    region = retriveRegionAroundContact_(voxelEntry,incrementalDistance);
    itk::ImageRegionIterator<ImageType> imageIterator(ctImage_,region);
    VoxelPointType p;
    PhysicalPointType tmp;  
    int num = 0;
    while(!imageIterator.IsAtEnd()){
      p = imageIterator.GetIndex();
      if (ctImage_->GetPixel(p) > 1000) {
	typedef itk::RegionOfInterestImageFilter<ImageType,ImageType> FilterType;
	typename FilterType::Pointer filter = FilterType::New();
	typename CalculatorType::Pointer calculator = CalculatorType::New();
	filter->SetInput(ctImage_);
	filter->SetRegionOfInterest(retriveRegionAroundContact_(p,3));
	calculator->SetImage(filter->GetOutput());
	try {
	  filter->Update();
	  calculator->Compute();
	  (*contact)[0] = calculator->GetCenterOfGravity()[0];
	  (*contact)[1] = calculator->GetCenterOfGravity()[1];
	  (*contact)[2] = calculator->GetCenterOfGravity()[2];
	} catch (itk::ExceptionObject &ex) {
	  cerr<<"Error computeNew Entry"<<__LINE__<<ex.what()<<endl;
	  return;
	}
	ctImage_->TransformIndexToPhysicalPoint(p,*contact);
	undoTranslatePhysicalPoint_(contact);
	return;
      }
      ++imageIterator;
      num++;
    }
    
    incrementalDistance += 2;
  }while (incrementalDistance < 10);
}



#endif //CONTACT_CONSTRUCTOR_H
