#ifndef ELECTRODE_TRAJECTORY_CONSTRUCTOR_H
#define ELECTRODE_TRAJECTORY_CONSTRUCTOR_H

#include <CmdParser.h>
#include <Definitions.h>


/*!
 * \brief Compute the trajectory of an electrode.
 * \details It uses the head and tail point computed from the entry
 *          and target point provided by the planning phase
 *  \author    Massimo Narizzano
 *  \author    Gabriele Arnulfo
 *  \version   1.0
 *  \date      2015
 *  \copyright GNU Public License.
 */
class ElectrodeTrajectoryConstructor {
 public:
  //! A constructor
  ElectrodeTrajectoryConstructor(ImageType::Pointer ctImage, CmdParser cmd);

  //! Main algorithm for the electrode trajectory computation.
  int update();  

 private:

  CmdParser _inputData; //!< Contains all the input data (from head to
			//! ct file)
  ImageType::Pointer _ctImage; //! A pointer to the CT image loaded
			       //! from file
  double _minRegionSize;  //! min region size used to construct
			  //! regions around points in order to search
			  //! for higher moment points
  double _maxRegionSize;  //! max region size used to construct
			  //! regions around points in order to search
			  //! for higher moment points

  unsigned long _threshold;      //! CT threshold under this value the point
			  //! in the ct are considered background
 
  //! Look for the head of the electrode in a Region around the entry
  PhysicalPointType _lookForHeadPoint(PhysicalPointType e);
  //! Look for the electrode's tail starting from the head
  PhysicalPointType _lookForTailPoint(PhysicalPointType h, PhysicalPointType t);
  //! Compute the electrode trajectory by using head and tail
  vector< PhysicalPointType> _computeTrajectory(PhysicalPointType h, PhysicalPointType t);

  //! Normalize the set of points representing a trajectory with a
  //! geometrical line
  vector< PhysicalPointType> _normalizeTrajectory(vector< PhysicalPointType > trajectory);

  //! Return the set of point of a cube centered in index with a side
  //! lenght of rSize
  RegionType _retrieveRegion(VoxelPointType index, int rSize);

  //! Return the CT value of the point
  double _getValue(PhysicalPointType point);

  //! Return the CT value of a cubic region centered in point and size
  //! regionSize
  double _getValue(PhysicalPointType point, double regionSize); 

  //! Return the point with the higher moment in a cubic region
  //! centered in center and with a side lenght of minRegionSize. If
  //! it can not find a point, it enlarge the region untill
  //! maxRegionSize
  PhysicalPointType _getPointWithHigherMoment(PhysicalPointType center, 
					      int minRegionSize, int maxRegionSize);

  //! Return true if the point is a correct 3D point i.e. has
  //! coordinates different from MAX_VALUE
  bool _checkPoint(PhysicalPointType  p);
  
  //! Return a new point posiztion: the new point has an euclidean
  //! "distance" from "c", on the line "c1"-"c2"
  PhysicalPointType _getNextContact(PhysicalPointType c, PhysicalPointType c1, 
				    PhysicalPointType c2, double distance);

  //! return the point in the cubic region r with the higher CT value
  PhysicalPointType _getHigherValuePoint(RegionType r);

  //! return the cosin between two lines
  double _computeCosine(PhysicalPointType a1,PhysicalPointType a2,PhysicalPointType b1,PhysicalPointType b2);

  void _printPoint(char* t, PhysicalPointType p);
  void _printPointReversed(char* t, PhysicalPointType p);
  void _printPointReversed(PhysicalPointType p);

  unsigned long _computeThreshold( void );


};

//! \fn _getHigherValuePoint
//! return thepoint in the cubic region r with the higher CT value
PhysicalPointType ElectrodeTrajectoryConstructor::_getHigherValuePoint(RegionType r) {
  itk::ImageRegionIterator<ImageType> imageIterator(_ctImage,r);
  VoxelPointType p = imageIterator.GetIndex();
  PhysicalPointType maxValue;
  _ctImage->TransformIndexToPhysicalPoint(p,maxValue);
  ++imageIterator;
  PhysicalPointType tmp;

  while(!imageIterator.IsAtEnd()){
    VoxelPointType p = imageIterator.GetIndex();
    _ctImage->TransformIndexToPhysicalPoint(p,tmp);
    if (_getValue(tmp) > _getValue(maxValue)) maxValue = tmp; 
    ++imageIterator;
  }
  return maxValue;
}

//! \fn _lookForHeadPoint 
//! Look for a point into a region close to the entry point 
PhysicalPointType ElectrodeTrajectoryConstructor::_lookForHeadPoint(PhysicalPointType e){
  VoxelPointType    vcenter;
  
  _ctImage->TransformPhysicalPointToIndex(e,vcenter);


  RegionType region = _retrieveRegion(vcenter,_maxRegionSize);
  itk::ImageRegionIterator<ImageType> imageIterator(_ctImage,region);
  
  VoxelPointType p;
  PhysicalPointType tmp;  
  while(!imageIterator.IsAtEnd()){
    p = imageIterator.GetIndex();
    _ctImage->TransformIndexToPhysicalPoint(p,tmp);
  if ((_getValue(tmp) > _threshold) && (_getValue(tmp,_minRegionSize) > _minRegionSize * _threshold)) {
      return _getPointWithHigherMoment(tmp,_minRegionSize,_maxRegionSize);
    }
    ++imageIterator;
  }
  PhysicalPointType q;
  q[0] = MAX_VALUE;
  q[1] = MAX_VALUE;
  q[2] = MAX_VALUE;
  return q;
}

//! \fn _retrieveRegion
// Retrieve a region around a contact with rSize dimension
RegionType ElectrodeTrajectoryConstructor::_retrieveRegion(VoxelPointType index, int rSize) {
  SizeType size;
  RegionType region;
  SpacingType spacing = _ctImage->GetSpacing();
  for(unsigned int i=0;i<3;i++) {
    size[i]    = 2*rSize+1;
    index[i]   -= rSize;    
  }
  region.SetSize(size);
  region.SetIndex(index);
  return region;
}

//! \fn _getValue
// Return the value of a single point in the space
double ElectrodeTrajectoryConstructor::_getValue(PhysicalPointType point) {
  VoxelPointType    voxelPoint;
  _ctImage->TransformPhysicalPointToIndex(point,voxelPoint);

  if(_ctImage->GetLargestPossibleRegion().IsInside(voxelPoint) )
    return _ctImage->GetPixel(voxelPoint);
  else 
    return 0.0;
}

//! \fn _getValue
// Return the cumulative value of a single point inside a region
// centere in point and with the regionSize dimension
double ElectrodeTrajectoryConstructor::_getValue(PhysicalPointType point, double regionSize) {
  VoxelPointType    vcenter;
  _ctImage->TransformPhysicalPointToIndex(point,vcenter);
  RegionType region = _retrieveRegion(vcenter,regionSize);

  if (regionSize == 0) return _getValue(point);

  if(_ctImage->GetLargestPossibleRegion().IsInside(vcenter) &&
		  _ctImage->GetLargestPossibleRegion().IsInside(region)){

    itk::ImageRegionIterator<ImageType> imageIterator(_ctImage,region);
    VoxelPointType p;
    PhysicalPointType tmp;  
    int num = 0;
    double sum = 0.0;
    while(!imageIterator.IsAtEnd()){
      p = imageIterator.GetIndex();
      _ctImage->TransformIndexToPhysicalPoint(p,tmp);
      sum += _getValue(tmp);
      num++;
      ++imageIterator;
    }
    if (num > 0) return sum;
    return 0.0;
  }else return 0.0;
}

//! \fn _getPointWithHigherMoment
//! Calcola il punto con il maggior momento in un cubo di larghezza
//! regionSize e centro center.  Se il momento e' nullo incrementa la
//! dimensione fino ad un massimo di maxRegioneSize Se all'interno
//! della regione non si trova un punto con un momento != da 0 allora
//! ritorna il punto stesso.  
//! [TODO]: il cubo creato non ha lo stesso vettore direzione della
//! retta di cui stiamo calcolando il momento, e' un problema?
PhysicalPointType ElectrodeTrajectoryConstructor::_getPointWithHigherMoment(PhysicalPointType center, int minRegionSize, int maxRegionSize){
  VoxelPointType    vcenter; // Center in voxel coordinates
  FilterType::Pointer filter = FilterType::New();
  CalculatorType::Pointer calculator = CalculatorType::New();
  filter->SetInput(_ctImage);
  double regionSize = minRegionSize;
  if ((minRegionSize == 0) && (maxRegionSize == 0)) return center;
  do {
    // compute a cube region with size regionSize
    _ctImage->TransformPhysicalPointToIndex(center,vcenter);
    RegionType region = _retrieveRegion(vcenter,regionSize);
    if(_ctImage->GetLargestPossibleRegion().IsInside( region )){
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
	//! if In the region there is not a point with moment greater
	//! than 0 then recompute the center of mass enlarging the
	//! region
	// cerr<<"Error : " << "Momento Nullo" << __LINE__<<ex.what()<<endl;
	regionSize += 1;
      }
    } else {
      maxRegionSize--;
    }
  } while (regionSize < maxRegionSize);
  center[0] = MAX_VALUE;
  center[1] = MAX_VALUE;
  center[2] = MAX_VALUE;
  return center;
}

//! \fn update
//////////////////////////////////////////////////////////////////////
/// update is a function that compute the exact trajectory of the
/// input electrode given its head and tail points. If they are not
/// provided than it firstly compute the head of the electrode
/// (starting from the entry point) and the electrode's tail (using
/// both head and target point). Then compute the trajectory looking
/// for a possible trajectory connecting the head and the
/// tail. Finally it interpolates these points in order to get a more
/// precise trajectory.
//////////////////////////////////////////////////////////////////////
int ElectrodeTrajectoryConstructor::update( ) {
  PhysicalPointType  head   = _inputData.getHead();
  PhysicalPointType  tail   = _inputData.getTail();
  PhysicalPointType  entry  = _inputData.getEntry();
  PhysicalPointType  target = _inputData.getTarget();
  
  //! Preliminary check: One between head(tail) and entry(target)
  //! should not be null 
  if(!(_checkPoint(head) || _checkPoint(entry)) ||
     !(_checkPoint(tail) || _checkPoint(target))) 
    return -1;
  //! Step 1.1: Calculate the head point in a region around the entry
  //! point. @see _lookForHeadPoint
  if(!(_checkPoint(head))) head = _lookForHeadPoint(entry);
  //_printPointReversed("H",head);
  if(!(_checkPoint(head))) return -1;
  //! Step 1.2: Calculate the tail point computing the best trajectory
  //! from the head point to the target point. @see _lookForTailPoint
  if(!(_checkPoint(tail))) tail = _lookForTailPoint(head,target);
  if(!(_checkPoint(tail))) return -1;
  //! Step 2: Compute the trajectory
  vector < PhysicalPointType >  trajectory = _computeTrajectory(head,tail);
  
  for(unsigned i = 0; i < trajectory.size(); i++){
    _printPointReversed(trajectory[i]);
  }
  return 0;

  //! Step 3: Interpolate the points describing the trajectory
}
//! \fn ElectrodeTrajectoryConstructor
//! The Constructor
ElectrodeTrajectoryConstructor::ElectrodeTrajectoryConstructor(ImageType::Pointer ctImage, CmdParser cmd){
  _inputData = cmd;
  _ctImage = ctImage;
  //[TODO] : A way to calculate this number based on experiences?
  _minRegionSize = 3.0;  //! [TODO] Magic Number
  _maxRegionSize = 10.0; //! [TODO] Magic Number
  _threshold = cmd.getThreshold();
  if (_threshold == 0.0) _threshold = _computeThreshold();
  //cout << "threshold " << _threshold << endl;
  //_threshold = 656.0;
}

//! \fn _checkPoint
//! check if the input point p is a valid point (should not have a
//! MAX_VALUE as value for one of its coordinates
bool ElectrodeTrajectoryConstructor::_checkPoint(PhysicalPointType  p) {
  return ((p[0] != MAX_VALUE) &&
	  (p[1] != MAX_VALUE) &&
	  (p[2] != MAX_VALUE));
}

//! \fn _getNextContact 
//! Return a new contact: contact has an euclidean "distance" from
// "c", on the line "c1"-"c2"
PhysicalPointType ElectrodeTrajectoryConstructor::_getNextContact(PhysicalPointType c, 
						      PhysicalPointType c1, 
						      PhysicalPointType c2, 
						      double distance) {
  double t = (c.EuclideanDistanceTo(c1) + distance) / c1.EuclideanDistanceTo(c2);
  PhysicalPointType nextC;
  nextC[0] = c1[0] + (c2[0] - c1[0]) * t; // x
  nextC[1] = c1[1] + (c2[1] - c1[1]) * t; // y
  nextC[2] = c1[2] + (c2[2] - c1[2]) * t; // z
  return nextC;
}


//! \fn _lookForTailPoint 

//! The algorithm in order to compute the tail needs two points p1,p2
//! defining a stright line. Initially p1 is h (head) so the first
//! part of the algorithm (i) compute p2.  The goal of the algorithm
//! is to find the value of the tail, i.e. the tip of electrode. In
//! order to obtain the tail, ideally the algorithm compute a new
//! point p3 on the line of p1-p2. If p3 is good (it is not in the
//! white part, or does not deviate from the electrode trajectory)
//! then p2 became p1 and p3 became p2 and a new point value is
//! generated. The algorithm terminates when one of the conditions
//! below occurs (a) The difference between p3 and p2 is less than the
//! lenght of a contact (meaning that the points are too close) or (b)
//! p3 has a ct value less than the threshold or (c) it is too far
//! from the head point computed or (d) it is in the other emisphere.
PhysicalPointType ElectrodeTrajectoryConstructor::_lookForTailPoint(PhysicalPointType h, 
								    PhysicalPointType t) {
  PhysicalPointType p;
  PhysicalPointType p1 = h;
  PhysicalPointType p2;
  PhysicalPointType p3;
  PhysicalPointType c;
  double dist = 3.5;
  //! (i) compute the first value for p2
  p2 = _getNextContact(p1, p1, t, dist * 2);//! [TODO] MAGIC NUMBER
  p2 = _getPointWithHigherMoment(p2,_minRegionSize,_maxRegionSize);
  if (!(_checkPoint(p2))) return p2;
  //_printPointReversed("T2",p2);
  //! (ii) compute the first point outside the electrode trajectory
  p3 = _getNextContact(p2, p1, p2, dist); //! [TODO] MAGIC NUMBER
  p3 = _getPointWithHigherMoment(p3,_minRegionSize,_minRegionSize); 
  for (unsigned int i = 0; i < 20; i++) {
    p1 = p2; p2 = p3;
    p3 = _getNextContact(p2, p1, p2, dist); //! [TODO] MAGIC NUMBER
    p3 = _getPointWithHigherMoment(p3,_minRegionSize,_minRegionSize); 
    //! Point 1 does not exist any point with higher moment starting
    //! from p3
    if (!(_checkPoint(p3))) {
      p3 = _getNextContact(p2, p1, p2, dist); //! [TODO] MAGIC NUMBER
      //_printPointReversed("TX",p3);
      //cout <<"D: " << _getValue(p3)  << endl;
      break;
    } 
    //_printPointReversed("T3",p3);
    double d = p3.EuclideanDistanceTo(p2);
    //cout <<"D: " << d  << endl;
    //cout <<"V: " << _getValue(p3)  << " ; " << _getValue(p3,1)  << " ; " << _getValue(p3,2)  
    //	 << " ; " <<  _getValue(p3,3)  << endl; 
    if (d < 2.5) { //[TODO] Magic number
      break;
    } else if(_getValue(p3,1) < _threshold) { //! [TODO] Better
					      //! explanation 
      break;
    }
  }
  //! [TODO] Commentare bene questo passaggio un po complicato.
  if (_getValue(p3) < _threshold) { //[TODO] Magic Number
    p3 = p2;
  }
  double d = p3.EuclideanDistanceTo(p2) + 0.5;//[TODO] Magic Number
  PhysicalPointType p4 = p3;
  while (_getValue(p4) >= _threshold) { //[TODO] Magic Number
    p3 = p4;
    p4 = _getNextContact(p2, p1, p2, d);
    d += 0.25;
    //_printPointReversed("VV",p4);
    //cout << "V: " << _getValue(p4) << endl;
  } 
  return p3;
}

void ElectrodeTrajectoryConstructor::_printPoint(char* t, PhysicalPointType p) {
  cout << t << "," << p[0] << "," << p[1] << "," << p[2] << endl;
}

void ElectrodeTrajectoryConstructor::_printPointReversed(char* t, PhysicalPointType p) {
  cout << t << "," << -1*p[0] << "," << -1*p[1] << "," << p[2] << endl;
}

void ElectrodeTrajectoryConstructor::_printPointReversed(PhysicalPointType p) {
  cout << -1*p[0] << endl << -1*p[1] << endl << p[2] << endl;
}


//! Compute the electrode trajectory by using head and tail
// [TODO] il modello è embeddato dentro un array da rivedere.
vector< PhysicalPointType> ElectrodeTrajectoryConstructor::_computeTrajectory(PhysicalPointType h, PhysicalPointType t) {
  vector< float > model = _inputData.getModel();
  float N = model[0]; // nunber of contacts
  float L = model[1]; // lenght of each contact
  float R = model[2]; // radius of the contact cylinder
  vector< PhysicalPointType> contactsPoint;

  // Compute the first contact. It should be the center of the
  // cylinder, with distance L/2 from the tip (tail).
  PhysicalPointType c = _getNextContact(t,t,h,L/2);
  PhysicalPointType c1 = _getPointWithHigherMoment(c,_minRegionSize,_minRegionSize);
  vector< PhysicalPointType> electrode;
  electrode.push_back((_checkPoint(c1) ? c1 : c));
  float distance;
  //_printPointReversed(c);
  c = electrode[electrode.size() -1];
  for(unsigned i = 3; i < model.size(); i++){
    PhysicalPointType last = electrode[electrode.size() -1];
    distance = L + model[i];
    c = _getNextContact(c,t,h,distance);
    c1 = _getPointWithHigherMoment(c,_minRegionSize,_minRegionSize);
    // [NB] c1 should be checked for NaN, but since NaN distance is is
    // more than 4.0 it is not necessary
    float d = last.EuclideanDistanceTo(c1);
    // [TODO] MAGIC NUMBERS distance beetween 2 contact +-0.5
    // [TODO] MAGIC NUMBERS angle beetween 2 contact less than 10 degree
    double angle = _computeCosine(last,c,last,c1);
    if ((angle < MAX_ANGLE) || ((d < 3.0) || (d > 4.0))){
      //cout << "Ho pushato il vincolato " << endl;
      electrode.push_back(c);
      //_printPointReversed("H",c);
    }else {
      electrode.push_back(c1);
      //_printPointReversed("H",c1);
    }
   
    // cout << i - 2 << ": <d,angle,MAX> : " << d << " , " <<  angle << " , " <<  MAX_ANGLE << endl; 
  }
  return electrode;
}


/*cos rs = l1*l2+m1*m2+n1*n2/modulo v1 * modulo v2*/
double ElectrodeTrajectoryConstructor::_computeCosine(PhysicalPointType a1,PhysicalPointType a2,PhysicalPointType b1,PhysicalPointType b2){
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



unsigned long ElectrodeTrajectoryConstructor::_computeThreshold( void ) {
  // Non va bene, bisognerebbe considerare solo i valori > di una soglia minima
  // visto che ci sono troppi punti = a 0;
  // Idea : fare una regione grande quanto un immagine (size = 255/255/255?)
  // Fare un filtro e iterare sulla regione e calcolare Mean/std/Min/Max a mano)

  ImageType::RegionType region = _ctImage->GetLargestPossibleRegion();
  itk::ImageRegionIterator<ImageType> imageIterator(_ctImage,region);
  double sum = 0.0;
  unsigned long value = 0.0;
  unsigned long min  = (unsigned long) MAX_VALUE;
  unsigned long max  = 0.0;
  int voxelTot = 0;
  int voxelNonZero = 0;
  vector< unsigned long > valuesVector;
  valuesVector.reserve(1); // [TODO] Magic Number

  while(!imageIterator.IsAtEnd()){
    value = _ctImage->GetPixel(imageIterator.GetIndex());
    voxelTot++;
    if (value > 0) {
      //  sum += value;
      voxelNonZero++;
      if (value < min) {min = value;}
      if (value > max) {max = value;}
      valuesVector.push_back(value);
    }
    ++imageIterator;
  }
  
  sum = 0.0;

  vector< int > statistics;
  statistics.resize(max + 1,0);
  for (unsigned int i = 1; i < valuesVector.size(); i++) {
    unsigned long v = valuesVector[i];
    statistics[v]++;
  }
  
  vector< unsigned long > tmp;
  tmp.resize(20,0.0);
  unsigned int index = 1;
  double basicProb = 0.05;
  sum = 0.0;
  for (unsigned int i = 1; i < statistics.size(); i++) {
    sum += statistics[i];
    double c = ((double)sum) / ((double) voxelNonZero);
    double p = 1.0;
    if (c > basicProb * index) {
      tmp[index] = i;
      index++;
    }
  }
  return tmp[9];

}

#endif
