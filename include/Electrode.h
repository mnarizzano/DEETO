#ifndef ELECTRODE_H
#define ELECTRODE_H

#include <itkPoint.h>
#include "ElectrodeModel.h"
/**
  This class represents the electrode structure
  */
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

  /** this method returns a pointer to HEAD of vector< Contact >*/  
  ContactIterator begin(){ return contacts_.begin();}

  /** this method returns a pointer to TAIL of vector< Contact >*/  
 ContactIterator end() {return contacts_.end();}

  /** this method returns a const pointer to HEAD of vector< Contact >*/  
  ConstContactIterator begin()const{return contacts_.begin();}

  /** this method returns a const pointer to TAIL of vector< Contact >*/  
  ConstContactIterator end()const{return contacts_.end();}

  //float getDistanceToNext(ulong next) const;
  //float getDistanceFromPrev(ulong prev) const;

  void addContact(Contact c) {
    contacts_.resize(contacts_.size() + 1, c);
  }

  /** get const pointer to contact given contact position along vector < Contact >
	@param id the contact index in vector
    @return NULL pointer in case of overflow (id > vector.size) */
  ConstContact* getContact(ulong id)const{ 
    if (id < contacts_.size()) return &contacts_[id];
    return NULL;
  }

  /** get pointer to contact given contact position along vector < Contact >
	@param id the contact index in vector
    @return NULL pointer in case of overflow (id > vector.size) */
  Contact* getContact(ulong id){ 
    if (id < contacts_.size()) return &contacts_[id];
    return NULL;
  }

  /** get number of contacts present in vector< Contact >*/
  ulong getContactNumber() const{ return contacts_.size();}

  /** this function returns the target point in mm as read from fiducial list*/
  Contact getTarget() const{ return targetPoint_; }

  /** this function returns the entry point in mm as read from fiducial list*/
  Contact getEntry() const{ return entryPoint_; }

   
  /** this function converts Contact target to double[3] target */
  void getTargetAsDouble(double* t) const{ for(short i=0;i<3;i++) t[i]=targetPoint_[i];}
  
  /** this function converts Contact entry to double[3] entry */
  void getEntryAsDouble(double* e) const{  for(short i=0;i<3;i++) e[i]=entryPoint_[i];}

  void setTarget(Contact c) { targetPoint_ = c;}
  void setEntry(Contact c) { entryPoint_ = c;}
 
  string getName() const{ return name_; }
  void setName( string name) { name_ = name; }

  void setModel(ElectrodeModel model);
  ElectrodeModel getModel(){return model_;};  


private:
  string 	     name_; /** electrode name usually in SEEG responds to ^\w[']?\d+ regexp which means it is of the form A1 (rh) as well as A'1 (lh)*/
  Contact	     targetPoint_; /** this is the target point, the most deep point around the electrode tip */
  Contact	     entryPoint_; /** this is the entry point on the scalp/dura-mater*/
  vector< Contact >  contacts_; /** this holds the reconstructed contact centroids*/
  ElectrodeModel     model_; /** this represents the electrode model */

};


#endif //ELECTRODE_H
