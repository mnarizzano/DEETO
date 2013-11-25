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
 private:
  
  string              name_; // may be better char*? It is usually
                             // 1 or 2 letters
  ulong               id_;
  ImagePointerType    ct_;
  vector< Electrode > headframe_;

};
#endif // CLINICAL_FRAME_H
 
