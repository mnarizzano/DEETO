/** ASSUME: CT is nifti, so must be RAS and Ref.  for this reason we
    assume that the fiducial list *have* to be in RAS and Ref
    format.
    
    NOTICE: ITKReader transform automatically the CT into LPS, so we
    need to do the same for the fiducial lit.  

    TODO: FCSVReader legge il file direttamente dalla command line,
    per cui l'opzione di file reader e' lui che deve aggiungerla.
**/ 
#ifndef FCSV_READER_H
#define FCSV_READER_H

#include <Definitions.h>
#include <tclap/CmdLine.h>

/**
  This class reads entry and target points from fiducial file and
  outputs the clinical frame.  this assumes that fiducial data are
  represented in LPS - Centered space. Usually file constructed with
 3DSlicer are defined in this space.
**/
class FCSVReader {
public:

 /* FCSVReader( void ) : optCent_("c","centered","File fcsv is assumed in Ref, if it not enable this flag",c,false){}; */
 FCSVReader( TCLAP::CmdLine* c):
  optCent_("r","noref","File fcsv is assumed in Ref, this flag on allow the file fcsv to be in centered",false){
    c->add(optCent_);
  };
 FCSVReader(string* filein, TCLAP::CmdLine* c):
    optCent_("c","centered","File fcsv is assumed in Ref, if it not enable this flag",false) {
    c->add(optCent_);
  };
  ~FCSVReader(){
    filein_ = NULL;
    headframe_ = NULL;
  }
  // setter methods // 
  void setFileInput(string* filein) { filein_ = filein;}
  void setClinicalFrame(ClinicalFrame* cf){ headframe_ = cf; }
  void setCT(ImageType::Pointer ctImage);

  /** This function actually reads the fiducial file and populate the
   ClinicalFrame information it's not important the order of
   entry/target points till they are represented in LPS-Centered
   space.  This function computes the distance from the center (0,0,0)
   to understand whether a coordiante triplet is a target or entry
   point.  Comments at the beginning of file are ignored.
  **/
  int update(void);  

  /** returns a pointer to the constructed ClinicalFrame */
  ClinicalFrame* getOutput() { return headframe_; }
  
 private:
  //  const static int MAX_NUMBER_OF_ELECTRODES = 20;

  string*                 filein_;  /** File where are stored the target/entry points.*/
  ImageType::Pointer    ctImage_;  /** Input CT, it is necessary for
                                    electrode reconstruction */
  ClinicalFrame*        headframe_; /** clinical frame object */
  TCLAP::SwitchArg optCent_;

  /** read a line from the file that should be a point. */
  PhysicalPointType readPoint(ifstream* file );

  struct fiducialPoint{
	string name;
	PhysicalPointType point;

	bool operator==(fiducialPoint a){
		return name == a.name;
	}
  };

};

int FCSVReader::update(void){
  // read from a file as written in filein_
  string str;
	string name;
  ifstream file;
	PhysicalPointType target;
	PhysicalPointType entry;
  vector< fiducialPoint > elements;
  
  file.open(filein_->c_str(), ios::in);

  assert(file.good());

  if (file.is_open()) {
    // Comments at the beginning of the file are eliminated
    while(!file.eof() && (file.peek() == '#')) {
      getline(file,str);
    }
    while(!file.eof()){
      // First read the name of the electrode.
      getline(file,name,',');      
      // The first 3 are number of interest representing a Point
      
      fiducialPoint p;
      p.name = name;
      p.point = readPoint(&file);
      
      elements.push_back(p);
      
      // skip what it is left.
      getline(file,str,'\n');
    } 
    
    // check size of both points and names 
    vector< fiducialPoint >::iterator it;
    
    for(it=elements.begin(); it != elements.end(); it++){
      // search for correspondence
      vector< fiducialPoint>::iterator next_it = find(it+1,elements.end(),*it);
      
      if( next_it != elements.end()){
		target = it->point;
		entry  = next_it->point;
		name = it->name;
		
		// add the contact only if name exist otherwise it means a blank line was found at the end of fcsv      
		double distance = (pow(target[0],2.0) + pow(target[1],2.0) + pow(target[2],2.0)) - 
		  (pow(entry[0],2.0) + pow(entry[1],2.0) + pow(entry[2],2.0));    
		
		// Convert the fcsv points read into the CT space
		if (optCent_.getValue() == true) {
		  headframe_->fromCenterToRef_(&entry);  // traslation from center to ref space
		  headframe_->fromCenterToRef_(&target); // traslation from center to ref space
		}
		// FILE FCSV is assumed in RAS (like ct) but since itk uses
		// LPS we need to transform the point to LPS
		headframe_->fromRAS2LPS_(&entry);      // from the LPS space to a RAS space      
		headframe_->fromRAS2LPS_(&target);     // from the LPS space to a RAS space
		cout<<name<<" "<<target<<" "<<entry<<" "<<endl;
		// Create a new electrode with target and entry (swapped if the target point is closer to the Origin)
		headframe_->addElectrode(Electrode(name,(distance > 0 ? entry : target),(distance > 0 ? target : entry)));
      }
    }
  }
  return 1;
}

/** Read a line of the file looking for a point (either a target or an
 entry point) */
PhysicalPointType FCSVReader::readPoint(ifstream* file ) {
  long j = 0;
  string str;
  PhysicalPointType point;
  while((j < 4) && (!file->eof())) {
    getline(*file,str,',');
    std::istringstream i(str);
    double x;
    if ((i >> x) && (j < 3)) point[j] = x;
    j++;    
  }
  return point;
}

#endif //ELECTRODE_H
