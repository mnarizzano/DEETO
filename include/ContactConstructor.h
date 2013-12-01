//TODO : 
//  - Scrivere la descrizione dell'algoritmo di update per doxygen
//  - Fattorizzare meglio l'algoritmo di update.
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


  RegionType retriveRegionAroundContact_(VoxelPointType index, int regionDim);
  void printContact_(string name,int  number,PhysicalPointType point);
  double getValue_(PhysicalPointType point);
  void computeNewEntry_(PhysicalPointType* contact, PhysicalPointType entry, PhysicalPointType target);
  PhysicalPointType getContact_(PhysicalPointType c, PhysicalPointType c1, PhysicalPointType c2, double distance);
  PhysicalPointType getBestContact_(PhysicalPointType prevContact, PhysicalPointType nextContact);
};

/*!  This function takes a set of Electrodes where only target and
  entry point are setted and then reconstruct the entire set of
  contatcs between the entry and the target */
void ContactConstructor::update( void ){
  ClinicalFrame::ElectrodeIterator electrodeItr = headFrame_->begin();
  double dist = 0.0;
  while(electrodeItr != headFrame_->end()) {
    // given a point C, distance represent the difference beetwenn the distance
    // entry-target and the distance entry-C. If it is greater then 0
    // than C position has gone over the target, that means that the algorithm should stop
    uint contactNum = 0;
    
    PhysicalPointType nextContact;
    PhysicalPointType entryPoint = electrodeItr->getEntry(); // set the first contact to the entry point
    PhysicalPointType targetPoint = electrodeItr->getTarget(); // set the first contact to the entry point
    printContact_(electrodeItr->getName(),0,entryPoint);
    printContact_(electrodeItr->getName(),0,targetPoint);
    
    PhysicalPointType contact1 = targetPoint;
    PhysicalPointType contact2;
    double distance = 3.1;
    if (getValue_(entryPoint) == 0) 
      computeNewEntry_(&entryPoint, entryPoint, contact1); // If the point is into the void ....
    
    contact1 = getBestContact_(entryPoint,entryPoint);
    electrodeItr->addContact(contact1);
    contactNum++;
    contact2 = getBestContact_(contact1,getContact_(contact1,contact1,targetPoint,distance));
    electrodeItr->addContact(contact2);
    contactNum++;
    
    do {
      nextContact = getBestContact_(contact2,getContact_(contact2,contact1,contact2,distance));
      if(contact2.EuclideanDistanceTo(nextContact) > 1.0) { //contact2!=nextContact (decimals)
	electrodeItr->addContact(nextContact);
	contact1 = contact2;
	contact2 = nextContact;
	distance = 3.1;
	contactNum++;
      } else {
	distance += 0.5;
      }
    } while ((targetPoint.EuclideanDistanceTo(entryPoint) > (entryPoint.EuclideanDistanceTo(nextContact) + 3.5)) && (distance <= 4.5)); 
    // TODO: 1.5 e' un numero a caso per evitare che salti l'ultimo dei contatti.
    electrodeItr++;
  }
}


// Return a new contact: 
// contact has an euclidean "distance" with "c", on the line "c1"-"c2"
PhysicalPointType ContactConstructor::getContact_(PhysicalPointType c, PhysicalPointType c1, PhysicalPointType c2, double distance) {
  double t = (c.EuclideanDistanceTo(c1) + distance) / c1.EuclideanDistanceTo(c2);
  PhysicalPointType nextC;
  nextC[0] = c1[0] + (c2[0] - c1[0]) * t; // x
  nextC[1] = c1[1] + (c2[1] - c1[1]) * t; // y
  nextC[2] = c1[2] + (c2[2] - c1[2]) * t; // z
  return nextC;
}

RegionType ContactConstructor::retriveRegionAroundContact_(VoxelPointType index, int regionDim) {
  SizeType size;
  RegionType region;
  SpacingType spacing = ctImage_->GetSpacing();
   
  for(unsigned int i=0;i<3;i++) {
    size[i]     = 2*((long int)(ceil(spacing[i] * regionDim)+1));
    index[i]   -= (long int)(ceil(spacing[i] * regionDim));
  }
  size[2]=(long int)ceil(size[1]-1); // ???? why ????
  region.SetSize(size);
  region.SetIndex(index);
  return region;
}

void ContactConstructor::printContact_(string name,int number,PhysicalPointType point) {
  //headFrame_->fromLPS2RAS_(&point);
  //headFrame_->fromRefToCenter_(&point);
  cout << name << number<<","<< point[0] << "," << point[1] << "," << point[2] <<",1,1" <<endl;  
}

double ContactConstructor::getValue_(PhysicalPointType point) {
  VoxelPointType    voxelPoint;
  ctImage_->TransformPhysicalPointToIndex(point,voxelPoint);
  return ctImage_->GetPixel(voxelPoint);
}

// [TODO] refactoring
// It tries to find an entry point that does not have null value :
// 1) First in an incremental region around the entry point if looks
//    for a voxel that has value != 0.
// 2) From this point it looks for the point having maximal momentum (p)
// 3) Then the new entry is the projection of the entry point on the
//    line from p to target. (i.e. the intersection betwen line p-target
//    and the line passing for the entry and ortogonal to the line
//    p-target
void ContactConstructor::computeNewEntry_(PhysicalPointType* contact, PhysicalPointType entry, PhysicalPointType target){
  int incrementalDistance = 3;
  PhysicalPointType  physicalEntry = entry;
  VoxelPointType     voxelEntry;
  PhysicalPointType  pippo;

  typename ImageType::RegionType region;
  //translatePhysicalPoint_(&physicalEntry);
  ctImage_->TransformPhysicalPointToIndex(physicalEntry,voxelEntry);

  do{
    region = retriveRegionAroundContact_(voxelEntry,incrementalDistance);
    itk::ImageRegionIterator<ImageType> imageIterator(ctImage_,region);
    VoxelPointType p;
    PhysicalPointType tmp;  
    int num = 0;
    while(!imageIterator.IsAtEnd()){
      p = imageIterator.GetIndex();
      // TODO 1000 e' una stima a caso, dovrebbe forse essere
      // calcolata sui punti neri della CT? Si prende cioe' una
      // immagine grossa come tutta la CT e poi si itera e si calcola la
      // media/varianza/min/max e si trova la costante
      if (ctImage_->GetPixel(p) > 1000) {
	
	FilterType::Pointer filter = FilterType::New();
	CalculatorType::Pointer calculator = CalculatorType::New();
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
	// TODO una volta trovato un contatto 

	//undoTranslatePhysicalPoint_(contact);
	return;
      }
      ++imageIterator;
      num++;
    }
    
    incrementalDistance += 2;
  }while (incrementalDistance < 10);
}


PhysicalPointType ContactConstructor::getBestContact_(PhysicalPointType prevContact, PhysicalPointType nextContact){
  VoxelPointType    nextVoxel;    
  FilterType::Pointer filter = FilterType::New();
  CalculatorType::Pointer calculator = CalculatorType::New();  
  filter->SetInput(ctImage_);

  uint k = 0;
  double dist = 0.0;
  do {
    ctImage_->TransformPhysicalPointToIndex(nextContact,nextVoxel);
    filter->SetRegionOfInterest(retriveRegionAroundContact_(nextVoxel,3));
    calculator->SetImage(filter->GetOutput());
    
    try {
      filter->Update();
      calculator->Compute();
      (nextContact)[0] = calculator->GetCenterOfGravity()[0];
      (nextContact)[1] = calculator->GetCenterOfGravity()[1];
      (nextContact)[2] = calculator->GetCenterOfGravity()[2];
    } catch (itk::ExceptionObject &ex) {
      cerr<<"Error : " << "Momento Nullo" << __LINE__<<ex.what()<<endl;
      return prevContact;
    }
    k++;
    dist = prevContact.EuclideanDistanceTo(nextContact);
  } while ((k < 10) && (dist <= 3.8) && (dist >= 2.3));
  return nextContact;
}

#endif //CONTACT_CONSTRUCTOR_H
