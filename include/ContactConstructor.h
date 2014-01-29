// TODO : 
//  - Scrivere la descrizione dell'algoritmo di update per doxygen
//  - Le costanti usate, farle diventare tali
#ifndef CONTACT_CONSTRUCTOR_H
#define CONTACT_CONSTRUCTOR_H

#include "Definitions.h"
#include "Electrode.h"
#include "ClinicalFrame.h"


class ContactConstructor {

 public:
  const static double MAX_ANGLE  = 0.988;
  //double maxAngle= 0.984807753; // dieci gradi
  //double maxAngle = 0.996194698; // cinque gradi

  ContactConstructor(  ImageType::Pointer ctImage, ClinicalFrame* headFrame, TCLAP::CmdLine* c ) {
    ctImage_   = ctImage;
    headFrame_ = headFrame;
    //loadStatistics_();
  }

  ContactConstructor(  ImageType::Pointer ctImage, ClinicalFrame* headFrame) {
    ctImage_   = ctImage;
    headFrame_ = headFrame;
    //loadStatistics_();
  }

  ~ContactConstructor(){}
  
  void update( void );
  
 private:
  ImageType::Pointer ctImage_;
  ClinicalFrame*     headFrame_;
  
  double             angle_; 

  RegionType retriveRegionAroundContact_(VoxelPointType index, int regionDim);
  void printContact_(string name,int  number,PhysicalPointType point);
  double getValue_(PhysicalPointType point);
  double getValue2_(PhysicalPointType point, double regionSize); // questo perche' un centro di massa potrebbe aver valore nullo
  PhysicalPointType getPointWithHigherMoment_(PhysicalPointType center, int minRegionSize, int maxRegionSize);
  PhysicalPointType getNextContact_(PhysicalPointType c, PhysicalPointType c1, PhysicalPointType c2, double distance);
  PhysicalPointType lookForTargetPoint_(PhysicalPointType entryPoint, PhysicalPointType targetPoint, int regionSize, int maxRegionSize);
  PhysicalPointType lookForEntryPoint_(PhysicalPointType entryPoint,int regionSize, int maxRegionSize);
  void printRegion_(RegionType region);
  double computeCos(PhysicalPointType a1,PhysicalPointType a2,PhysicalPointType b1,PhysicalPointType b2);
  double loadStatistics_( void );
  double distanceToSurface_(PhysicalPointType p1,PhysicalPointType p2,PhysicalPointType p);
};

// Calcola il punto con il maggior momento in un cubo di larghezza regionSize e centro center. 
// Se il momento e' nullo incrementa la dimensione fino ad un massimo di maxRegioneSize
// Se all'interno della regione non si trova un punto con un momento
// != da 0 allora ritorna il punto stesso.
// Notice: che dipende fortemente da come e' orientata la retta su cui cerchiamo i punti, da fare qualcosa?
PhysicalPointType ContactConstructor::getPointWithHigherMoment_(PhysicalPointType center, int minRegionSize, int maxRegionSize){
  VoxelPointType    vcenter; // Center in voxel coordinates
  FilterType::Pointer filter = FilterType::New();
  CalculatorType::Pointer calculator = CalculatorType::New();
  filter->SetInput(ctImage_);
  double regionSize = minRegionSize;
  do {
    ctImage_->TransformPhysicalPointToIndex(center,vcenter);
	RegionType region = retriveRegionAroundContact_(vcenter,regionSize);
	if(ctImage_->GetLargestPossibleRegion().IsInside( region )){
		filter->SetRegionOfInterest(region );
		calculator->SetImage(filter->GetOutput());
		try {
		  filter->Update();
		  calculator->Compute();
		  center[0] = calculator->GetCenterOfGravity()[0]; 
		  center[1] = calculator->GetCenterOfGravity()[1]; 
		  center[2] = calculator->GetCenterOfGravity()[2]; 
		  //cout << "M " << calculator->GetTotalMass() << endl;
		  return center; 
		} catch (itk::ExceptionObject &ex) {
		  //cerr<<"Error : " << "Momento Nullo" << __LINE__<<ex.what()<<endl;
		  regionSize += 1;
		}
	} else {
		maxRegionSize--;
	}
  } while (regionSize < maxRegionSize);
  return center;
}

void ContactConstructor::update( void ){
  ClinicalFrame::ElectrodeIterator electrodeItr = headFrame_->begin();
  
  while(electrodeItr != headFrame_->end()) {
    PhysicalPointType entryPoint = electrodeItr->getEntry(); // set the first contact to the entry point
    PhysicalPointType targetPoint = electrodeItr->getTarget(); // set the first contact to the entry point
    printContact_(electrodeItr->getName(),0,entryPoint);
    printContact_(electrodeItr->getName(),0,targetPoint);

    int regionSize = 3;
    int maxRegionSize = 7;
    int k = 1;
    entryPoint = lookForEntryPoint_(entryPoint,regionSize,maxRegionSize);
    targetPoint = lookForTargetPoint_(entryPoint,targetPoint,regionSize,(maxRegionSize - 2)); // -2 perche' in teoria si e' sulla linea giusta ...
    PhysicalPointType c;                   // candidate
    PhysicalPointType cprime;              // best candidate
    PhysicalPointType r1 = targetPoint;    // primo punto per calcolare la retta
    PhysicalPointType r2 = entryPoint;     // secondo punto per calcolare la retta
    PhysicalPointType start = targetPoint; // punto a partire dal quale si calcola
                                           // il nuovo punto sulla retta r1-r2
    double angle = 0.0;
    double distance = 3.5;
    double delta = 0.3;
    int rs = regionSize;

//    printContact_(electrodeItr->getName(),0,entryPoint);
//    printContact_(electrodeItr->getName(),k,targetPoint);
    // pezza perche' il target point va fuori 
    if (getValue2_(targetPoint,rs) > 7000) {
      electrodeItr->addContact(targetPoint);
      k++;
    }
    // Inizio cerca dei punti
    do {

      // punto candidato
      c = getNextContact_(start,r1,r2,distance);
      //printContact_("C",k,c);
      // centro di massa
      cprime = getPointWithHigherMoment_(c,rs,rs);
      //printContact_("C'",k,cprime);
      // calcolo angolo di deviazione tra il cprime e i punti precedenti
      if ((r2.EuclideanDistanceTo(cprime) < 0.001) || (r2.EuclideanDistanceTo(entryPoint) < 0.001)) 
			angle = computeCos(r1,r2,r1,cprime);
      else angle = computeCos(r1,r2,r2,cprime);
      
      //cout << angle << " : " << r2.EuclideanDistanceTo(cprime) << " : " << getValue2_(cprime,rs) << " : " << rs << endl;

      if((angle <= MAX_ANGLE) && (rs > 1)) {
		//distance = 3.2;
		rs -= 1;
		//cout << "Region Size " << rs << endl;
		//  printContact_("S",k,n2);
      } else if ((r2.EuclideanDistanceTo(entryPoint) > 0.1) &&                            // se non e' il primo punto.
		 ((r2.EuclideanDistanceTo(cprime) > (distance + delta)) ||
		  (r2.EuclideanDistanceTo(cprime)  < (distance - delta))) && (rs > 1)) {
			rs -= 1;
      } else { 
		if (rs == 1) {
		  if (//(angle <= MAX_ANGLE) || 
			  ((r2.EuclideanDistanceTo(entryPoint) > 0.1) &&                            // se non e' il primo punto.
			  ((r2.EuclideanDistanceTo(cprime) > (distance + delta)) ||
			   (r2.EuclideanDistanceTo(cprime)  < (distance - delta)))))
			cprime = c;
		}
	
		if (getValue2_(cprime,rs)  > (rs*1500)) { // getValue2 calcola il momento
       
		  rs = regionSize;
		  if (r1.EuclideanDistanceTo(targetPoint) > 0.1) r1 = r2;
		  //cout << "D: " << r2.EuclideanDistanceTo(cprime) << endl;
		  r2 = cprime;
		  start = cprime;
		  electrodeItr->addContact(cprime);
		  printContact_(electrodeItr->getName(),k,cprime);
		  k++;
		}
      }
    }while((getValue2_(cprime,rs)  > (rs*1500)) && (rs >= 1) && (k < 21));

    electrodeItr++;
  }
}

RegionType ContactConstructor::retriveRegionAroundContact_(VoxelPointType index, int regionDim) {
  SizeType size;
  RegionType region;
  SpacingType spacing = ctImage_->GetSpacing();
  //PhysicalPointType tmp;
  //ctImage_->TransformIndexToPhysicalPoint(index,tmp);
  //printContact_("C",0,tmp);
  for(unsigned int i=0;i<3;i++) {
    size[i]    = 2*regionDim+1;
    index[i]   -= regionDim;    
  }
  region.SetSize(size);
  region.SetIndex(index);
  //ctImage_->TransformIndexToPhysicalPoint(index,tmp);
  //  printContact_("C",1,tmp);  
  //printRegion_(region);

  return region;
}

void ContactConstructor::printContact_(string name,int number,PhysicalPointType point) {
  cout << name << number<<","<< point[0] << "," << point[1] << "," << point[2] <<",1,1" <<endl;  
}

double ContactConstructor::getValue_(PhysicalPointType point) {
  VoxelPointType    voxelPoint;
  ctImage_->TransformPhysicalPointToIndex(point,voxelPoint);

  if(ctImage_->GetLargestPossibleRegion().IsInside(voxelPoint) )
	  return ctImage_->GetPixel(voxelPoint);
    else 
	  return 0.0;
}

double ContactConstructor::getValue2_(PhysicalPointType point, double regionSize) {
  VoxelPointType    vcenter;
  ctImage_->TransformPhysicalPointToIndex(point,vcenter);
  RegionType region = retriveRegionAroundContact_(vcenter,regionSize);

  if(ctImage_->GetLargestPossibleRegion().IsInside(vcenter) &&
		  ctImage_->GetLargestPossibleRegion().IsInside(region)){

	  itk::ImageRegionIterator<ImageType> imageIterator(ctImage_,region);
	  VoxelPointType p;
	  PhysicalPointType tmp;  
	  int num = 0;
	  double sum = 0.0;
	  while(!imageIterator.IsAtEnd()){
		p = imageIterator.GetIndex();
		ctImage_->TransformIndexToPhysicalPoint(p,tmp);
		sum += getValue_(tmp);
		num++;
		++imageIterator;
	  }
	  if (num > 0) return sum;
	  return 0;
  }else return 0.0;
}


// Return a new contact:
// contact has an euclidean "distance" with "c", on the line "c1"-"c2"
PhysicalPointType ContactConstructor::getNextContact_(PhysicalPointType c, PhysicalPointType c1, PhysicalPointType c2, double distance) {
  double t = (c.EuclideanDistanceTo(c1) + distance) / c1.EuclideanDistanceTo(c2);
  PhysicalPointType nextC;
  nextC[0] = c1[0] + (c2[0] - c1[0]) * t; // x
  nextC[1] = c1[1] + (c2[1] - c1[1]) * t; // y
  nextC[2] = c1[2] + (c2[2] - c1[2]) * t; // z
  return nextC;
}

// Look for an Entry point
PhysicalPointType ContactConstructor::lookForEntryPoint_(PhysicalPointType entryPoint,int regionSize, int maxRegionSize){
  PhysicalPointType n1 = entryPoint;
  PhysicalPointType n2;
  uint k = 0;
  do {
    n2 = getPointWithHigherMoment_(n1,regionSize,maxRegionSize);
    if(n2.EuclideanDistanceTo(n1) < 0.1){ // n1 == n2
      regionSize += 1;
    } else {
      n1 = n2;
      //printContact_("CC",k,n1);
      k++;
    }
    
  } while (regionSize <= maxRegionSize);
  return n2;
}


// Look for the target point (e' la punta dell'elettrodo)
PhysicalPointType ContactConstructor::lookForTargetPoint_(PhysicalPointType entryPoint, PhysicalPointType targetPoint, int regionSize, int maxRegionSize){

  PhysicalPointType n2;
  PhysicalPointType c; // candidate
  PhysicalPointType r1; // primo punto per calcolare la retta
  PhysicalPointType r2; // secondo punto per calcolare la retta
  PhysicalPointType start; // punto a partire dal quale si calcola il nuovo punto giacente sulla retta r1-r2
  double angle = 0.0;
  double distance = 3.2;
  int rs = regionSize;
  
  int k = 0;
  /* printContact_("T",k,entryPoint); */
  /* k++; */
  r1 = entryPoint;
  r2 = targetPoint;
  start = entryPoint;
  double size = 0.0;
  do {
    // punto candidato
    c = getNextContact_(start,r1,r2,distance);
    //printContact_("C",k,c);
    // centro di massa
    n2 = getPointWithHigherMoment_(c,rs,rs);
    // calcolo l'angolo tra il centro e i precedenti punti per vedere se ha deviato.
    //printContact_("N",k,n2);
    if ((r2.EuclideanDistanceTo(n2) < 0.001) || (r2.EuclideanDistanceTo(targetPoint) < 0.001)) angle = computeCos(r1,r2,r1,n2);
    else angle = computeCos(r1,r2,r2,n2);
    // Se il punto nuovo C viene preso nel vuoto cosmico allora il
    // centro di massa o e uguale a n1 oppure e' anche lui nel vuoto
    // cosmico' allora bisogna prendere un nuovo punto piu' distante
    // (distance += 0.5)
    //cout << angle << " : " << r2.EuclideanDistanceTo(n2) << " : " << getValue_(n2) << " : " << rs << endl;
    if ((r2.EuclideanDistanceTo(n2) < 0.001) || (getValue_(n2) < 500)) {
      rs = regionSize;
      distance += 0.5;
      //cout << "DIST " << distance << endl;
      //printContact_("D",k,n2);
    } else if((angle <= MAX_ANGLE) && (rs > 1)){
      //distance = 3.2;
      rs -= 1;
      //cout << "Region Size " << rs << endl;
      //  printContact_("S",k,n2);
    } else {
      if(angle <= MAX_ANGLE){
	if (getValue_(c) > 500) {
	  n2 = c;
	}
      }
      distance = 3.2;
      rs = regionSize;
      if (r2.EuclideanDistanceTo(targetPoint) > 0.1) r1 = r2;
      r2 = n2;
      start = n2;
      //printContact_("T",k,n2);
      k++;
    }
  } while ((distance < 11.5) && (entryPoint.EuclideanDistanceTo(c) <= entryPoint.EuclideanDistanceTo(targetPoint)));
  // TODO : Nuovo criterio di stop: non si deve superare l'emisfero in cui giace l'elettrodo, ergo il piano passante per il centro (0,0,0)
  distance = 0.5;
  c = n2;
  double d = entryPoint.EuclideanDistanceTo(n2) - distanceToSurface_(entryPoint,targetPoint,entryPoint);

  /// [TODO] se guarda solo il valore non va bene perche' se target point e' ad minchiam si ferma prima
  // Bisogna che continui per una distanza > 5.0 e si tenga in memoria l'ultimo valore > 500
    while ((distance < 10.5) && (d < 2.5)){
    if(getValue_(c) > 500) n2 = c;
    c = getNextContact_(start,r1,r2,distance);
    distance += 0.5;
    d = entryPoint.EuclideanDistanceTo(c) - distanceToSurface_(entryPoint,targetPoint,entryPoint);
    //printContact_("C",1,c);
  }
  //printContact_("C",1,c);
  c = getNextContact_(n2,n2,r1,1.0);
  //printContact_("K",2,c);
  n2 = getPointWithHigherMoment_(c,regionSize,regionSize);
  angle = computeCos(r1,r2,start,n2); // angolo tra higher moment e punti precedenti
  rs = regionSize;
  while ((rs > 1) && ( angle< MAX_ANGLE)){ 
    // se l'angolo e' troppo ampio (> 10 gradi) allora lo ricalcolo riducendo la regione TODO : controllo su come vengono calcolati gli angoli
    rs--;
    n2  = getPointWithHigherMoment_(c,rs,maxRegionSize);
    angle = computeCos(r1,r2,start,n2); // angolo tra higher moment e punti precedenti
    /* cout << "COS " <<  cos << endl; */
    /* printContact_("N",k,n2); */
  }
  if (angle < MAX_ANGLE) n2 = c;
  return n2;
}


void ContactConstructor::printRegion_(RegionType region){
  itk::ImageRegionIterator<ImageType> imageIterator(ctImage_,region);
  VoxelPointType p;
  PhysicalPointType tmp;  

  while(!imageIterator.IsAtEnd()){
    p = imageIterator.GetIndex();
    ctImage_->TransformIndexToPhysicalPoint(p,tmp);
    printContact_("",0,tmp);
    //cout << "0,"<<p << endl;
    ++imageIterator;
  }
}

/* Date due rette r ed s nello spazio aventi rispettivamente i
   parametri direttori v_1(l1, m1, n1) e v2(l2, m2, n2) */
/* l’angolo tra le due rette si ottiene da */

/*cos rs = l1*l2+m1*m2+n1*n2/modulo v1 * modulo v2*/
double ContactConstructor::computeCos(PhysicalPointType a1,PhysicalPointType a2,PhysicalPointType b1,PhysicalPointType b2){
  double l1 = a1[0] - a2[0];
  double m1 = a1[1] - a2[1];
  double n1 = a1[2] - a2[2];
  double l2 = b1[0] - b2[0];
  double m2 = b1[1] - b2[1];
  double n2 = b1[2] - b2[2];
  double arcos = (l1*l2 + m1*m2+n1*n2)/(sqrt(l1*l1+m1*m1+n1*n1)*sqrt(l2*l2+m2*m2+n2*n2));
  if (arcos > 0) return arcos;
  else return -1*arcos;
}


double ContactConstructor::loadStatistics_( void ) {
  // Non va bene, bisognerebbe considerare solo i valori > di una soglia minima (200/500)
  // visto che ci sono troppi punti = a 0;
  // Idea : fare una regione grande quanto un immagine (size = 255/255/255?)
  // Fare un filtro e iterare sulla regione e calcolare Mean/std/Min/Max a mano)
  ImageType::RegionType region = ctImage_->GetLargestPossibleRegion();
  itk::ImageRegionIterator<ImageType> imageIterator(ctImage_,region);
  double sum = 0.0;
  double value = 0.0;
  double std  = 0.0; 
  double mean = 0.0; 
  double min  = 115500.0; // num a caso molto grosso
  double max  = 0.0;
  int num = 0;
    
  while(!imageIterator.IsAtEnd()){
    
    value = ctImage_->GetPixel(imageIterator.GetIndex());
    if (value >= 500.0) {
      sum += value;
      max = (value >= max ? value : max);
      min = (value < min ? value : min);
      num++;
    }
    ++imageIterator;
  }
  mean = (num > 0 ? sum/num : 0.0);

  
  // standard deviation
  sum = 0.0;
  itk::ImageRegionIterator<ImageType> imageIterator2(ctImage_,region);
  while(!imageIterator2.IsAtEnd()){  
    value = ctImage_->GetPixel(imageIterator2.GetIndex());
    if (value >= 500.0) {
      sum += (mean - value) * (mean - value);
    }
    ++imageIterator2;
  }
  std = sqrt(sum)/num;
  cout << "min    :" << min << endl; 
  cout << "max :" << max << endl; 
  cout << "MEAN   : " << mean << endl;
  cout << "STD   : " << std << endl;
}

/* 
   Compute the distance between the point p from the surface passing
   for O(0,0,0) (RAS) and having vector director ortogonal to the
   stright line passing for (P2-P1)
 */
double ContactConstructor::distanceToSurface_(PhysicalPointType p1,PhysicalPointType p2,PhysicalPointType p){
  double d = abs((p2[0]-p1[0])*p[0] + (p2[1]-p1[1])*p[1] + (p2[2]-p1[2])*p[2]) / sqrt(pow((p2[0]-p1[0]),2.0) + pow((p2[1]-p1[1]),2.0) + pow((p2[2]-p1[2]),2.0));
  return d;
}
  
#endif //CONTACT_CONSTRUCTOR_H

 
