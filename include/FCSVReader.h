// ASSUME:
// CT is in *RAS* space and *Ref*
// while FCSV is in *LPS* and *Centered*
#ifndef FCSV_READER_H
#define FCSV_READER_H

#include <Definitions.h>

class FCSVReader {
public:
  
  void setFileInput(char* filein) { filein_ = filein;}
  void setClinicalFrame(ClinicalFrame* cf){ headframe_ = cf; }
  void setCT(ImageType::Pointer ctImage);
  void update(void);  
  ClinicalFrame* getOutput() { return headframe_; }

private:
  const static int MAX_NUMBER_OF_ELECTRODES = 20;

  char*                 filein_;   // File where are stored the target/entry points.
  ImageType::Pointer    ctImage_;  // Input CT, it is necessary for
                                   // electrode reconstruction
  ClinicalFrame*        headframe_;

  // read a line from the file that should be a point.
  PhysicalPointType readPoint(ifstream* file );

};

// Here we must add the constraint of how the file should be formatted
// ERROR: se il file ha una linea in piu' vuota, aggiunge l'ultimo
//        contatto due volte.
void FCSVReader::update(void){
  // read from a file as written in filein_
  string str;
  string name;
  ifstream file;
  PhysicalPointType target;
  PhysicalPointType entry;
  unsigned int k;
  
  file.open(filein_, ios::in);

  assert(file.good());

  if (file.is_open()) {
    // Comments at the beginning of the file are eliminated
    while(!file.eof() && (file.peek() == '#')) {
      getline(file,str);
    }
    while(!file.eof()){
      k = 0;
      // read two lines at the time.
      while (k < 2) {
	// First read the name of the electrode.
	getline(file,name,',');      
	// The first 3 are number of interest representing a Point
	if (k == 0) target = readPoint(&file);
	else entry = readPoint(&file);
	// skip what it is left.
	getline(file,str,'\n');
	// skip the name
	k++;
      }

      // add the contact only if name exist otherwise it means a blank line was found at the end of fcsv      
      if( name.length() >= 1) {
	double distance = (pow(target[0],2.0) + pow(target[1],2.0) + pow(target[2],2.0)) - (pow(entry[0],2.0) + pow(entry[1],2.0) + pow(entry[2],2.0));    
	// Convert the fcsv points read into the CT space
	headframe_->fromCenterToRef_(&entry);  // traslation from center to ref space
	headframe_->fromLPS2RAS_(&entry);      // from the LPS space to a RAS space      
	headframe_->fromCenterToRef_(&target); // traslation from center to ref space
	headframe_->fromLPS2RAS_(&target);     // from the LPS space to a RAS space
	// Create a new electrode with target and entry (swapped if the target point is closer to the Origin)
	headframe_->addElectrode(Electrode(name,(distance > 0 ? entry : target),(distance > 0 ? target : entry)));
      }
    }
  }
}

// Read a line of the file looking for a point (either a target or an
// entry point)
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
