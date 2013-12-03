#ifndef ELECTRODE_H
#define ELECTRODE_H

#include <itkPoint.h>
#include "ElectrodeModel.h"

class Electrode {

 public:
  
  typedef PhysicalPointType Contact;
  typedef const PhysicalPointType ConstContact;
  typedef vector< Contact >::iterator ContactIterator;
  typedef vector< Contact >::const_iterator ConstContactIterator;

  Electrode(string name, Contact& target, Contact& entry, TCLAP::CmdLine* c) { 
    setName(name);
    setTarget(target);
    setEntry(entry);
    contacts_.reserve(20); // TODO numero a caso, usare magari il numero custodito in model_
  };

  Electrode(string name, Contact& target, Contact& entry) { 
    setName(name);
    setTarget(target);
    setEntry(entry);
    contacts_.reserve(20); // TODO numero a caso, usare magari il numero custodito in model_
  };

  Electrode(string id, Contact& target, Contact& entry, ElectrodeModel m);
  ~Electrode(){};

  friend ostream& operator<<(ostream& os, const Electrode& obj){
	  ConstContactIterator it;
	  ulong n = obj.getContactNumber();

	  for(it = obj.begin(); it != obj.end(); it++){
		  os<<obj.getName()<<n--<<","<<(*it)[0]<<","<<(*it)[1]<<","<<(*it)[2]<<",1,1"<<endl;
	  }
	  return os;
  }

  
  ContactIterator begin(){ return contacts_.begin();}
  ConstContactIterator begin()const{return contacts_.begin();}
  ConstContactIterator end()const{return contacts_.end();}

  float getDistanceToNext(ulong next) const;
  float getDistanceFromPrev(ulong prev) const;

  void addContact(Contact c) {
    contacts_.resize(contacts_.size() + 1, c);
  }

  ConstContact* getContact(ulong id)const{ 
    if (id < contacts_.size()) return &contacts_[id];
    return NULL;
  }

  Contact* getContact(ulong id){ 
    if (id < contacts_.size()) return &contacts_[id];
    return NULL;
  }

  ulong getContactNumber() const{ return contacts_.size();}
  Contact getTarget() const{ return targetPoint_; }
  Contact getEntry() const{ return entryPoint_; }

  void getTargetAsDouble(double* t) const{ for(short i=0;i<3;i++) t[i]=targetPoint_[i];}
  
  void getEntryAsDouble(double* e) const{  for(short i=0;i<3;i++) e[i]=entryPoint_[i];}

  void setTarget(Contact c) { targetPoint_ = c;}
  void setEntry(Contact c) { entryPoint_ = c;}
  
  string getName() const{ return name_; }
  void setName( string name) { name_ = name; }

  void setModel(ElectrodeModel model);
  ElectrodeModel getModel(){return model_;};  
  void sort();

private:
  string 	     name_;
  Contact	     targetPoint_;
  Contact	     entryPoint_;
  vector< Contact >  contacts_;
  ElectrodeModel     model_;

};


#endif //ELECTRODE_H
