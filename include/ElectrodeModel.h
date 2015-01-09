#ifndef ELECTRODE_MODEL_H
#define ELECTRODE_MODEL_H
// This class stores into an array the distances between the
// contacts. With distance between contancts we mean distance between
// the two tip of the contacts.

#include <itkPoint.h>

class ElectrodeModel {
 public:
  typedef vector< double >::iterator DistanceIterator;

   // the first contact distance from noone is 0
  ElectrodeModel(){};// distances_.push_back(0.0);}
  ~ElectrodeModel(){}

  void setName(string s){
    name_ = s;
  }
  string getName() {
    return name_;
  }

  void setH(double h){
    h_ = h;
  }
  double getH() {
    return h_;
  }

  void setR(double r){
    r_ = r;
  }
  double getR() {
    return r_;
  }

  /** this method returns a pointer to HEAD of vector< double >*/  
  DistanceIterator begin(){ return distances_.begin();}

  /** this method returns a pointer to TAIL of vector< doublet >*/  
  DistanceIterator end() {return distances_.end();}


  // add a contact that has distance d from the previous
  void addContact(double d){
    distances_.push_back(d);
  }
  
  // compute the max distance between two contacts
  double getMaxDistance() {
    double max = distances_[2];
    for (int i = 3; i < distances_.size(); i++){
      if (distances_ [i] > max) max = distances_[i];
    }
    return max;
  }
 
  double getMinDistance() {
    double min = distances_[2]; // the first contacts is 
    for (int i = 3; i < distances_.size(); i++){
      cout << i << " -- " << distances_ [i]<< endl;
      if (distances_ [i] < min) min = distances_[i];
    }
    return min;
  }

  int getContactsNo(){
    return distances_.size();
  }
  
  

 private:
  // Stores the distances between 2 consecutives contacts; In other
  // words a position i, distances_[i] records the distance between
  // the contact i and the previous (i-1)
  vector< double > distances_;
  string name_;
  
  double h_; // lenght of the cylinder, i.e. a contact
  double r_; // radius of the base of the cylinder, i.e. a contact
    
};


#endif //ELECTRODE_MODEL_H
