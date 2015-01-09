/**
**/ 
#ifndef ELECTRODE_MODEL_READER_H
#define ELECTRODE_MODEL_READER_H

#include <Definitions.h>
#include <tclap/CmdLine.h>

/**
**/
class ElectrodeModelReader {
public:

 /* ElectrodeModelReader( TCLAP::CmdLine* c): */
 /*  file_db("d","db_name"," Data Base Name for the Electrode Type",false,"db-data/default-db.csv","string",c), */
 /*    file_models("m","model"," File that contains the models for the elctrodes defined in fcsv",false,"","string",c)  */
 /*      { */
      
 /*    }; */

  ElectrodeModelReader( void) {}
  ~ElectrodeModelReader(){ headFrame_ = NULL; }

  // setter methods // 
  void setClinicalFrame(ClinicalFrame* cf){ headFrame_ = cf; }
  ClinicalFrame* getClinicalFrame( void ){ return headFrame_; } 
  void setDBFile(string filein) { file_db_ = filein;}
  void setModelFile(string filein) { file_models_ = filein;}
  
  /** This funtion read eventually a file where are stored for each
      electrode which is its model. If such a file does not exists, or
      an electrode is not listed than the default model is used.
  **/
  int update(void);
  
 private:
  
  vector< ElectrodeModel > models_;
  ClinicalFrame*  headFrame_; /** clinical frame object */
  string          file_db_; 
  string          file_models_; 

  int loadModels_( void );


  /* TCLAP::VaelueArg<string> file_db; */
  /* TCLAP::ValueArg<string> file_models; */

};

int ElectrodeModelReader::update(void){
  vector< string > names;
  vector< ElectrodeModel > types;  

  // Loads the type of electrodes in models.
  if (loadModels_() == 0) return 0;
  
  // Loads the electrodes models, referred in fcsv file.
  ifstream file;  
  string str;
  string name;
  string type;
  
  if (file_models_.compare("") != 0) {
    // READ the file
    file.open(file_models_.c_str(), ios::in);
    // Comments at the beginning of the file are eliminated
    while(!file.eof() && (file.peek() == '#')) {
      getline(file,str);
    }
    while(!file.eof()){
      getline(file,name,',');
      getline(file,type,'\n');
      names.push_back(name);
      for(int i = 0; i < models_.size(); i++) {
	if (type.compare(models_[i].getName()) == 0) {
	  types.push_back(models_[i]);
	  break;
	}
      }
    }
  }
  // For each electrode in headframe_, we copy its model
  if (headFrame_ == NULL) return 0;
  ClinicalFrame::ElectrodeIterator electrodeItr = headFrame_->begin();
  ElectrodeModel defModel;
  ElectrodeModel m;

  for(int i = 0; i < models_.size(); i++) {
    name = models_[i].getName();
    if (name.compare("default") == 0) {
      defModel = models_[i];
      break;
    }
  }
  
  while(electrodeItr != headFrame_->end()) {
    name = electrodeItr->getName();
    m = defModel;
    for(int i = 0; i < names.size(); i++) {
      if (name.compare(names[i]) == 0){
	m = types[i];
	break;
      }
    }
    electrodeItr->setModel(m);
    electrodeItr++;
  }
  return 1;
}

int ElectrodeModelReader::loadModels_( void ){
  ifstream file;  
  string path;
  string name;
  string str; 

  // read each electrode model file create an ElectrodeModel
  file.open(file_db_.c_str(), ios::in);
  // Comments at the beginning of the file are eliminated
  while(!file.eof() && (file.peek() == '#')) {
    getline(file,str);
  }
  while(!file.eof()){
    // First read the name of the electrode.
    getline(file,name,',');      
    // Second read the path of the Electrode Model 
    getline(file,path,'\n');      
    // Construct all the ElectrodeModel
    int idx = models_.size();
    models_.resize(idx+1);

    // (0) First set the name 
    models_[idx].setName(name);
 
    // (READ the data in the file)
    ifstream modelsFile;
    modelsFile.open(path.c_str(), ios::in);
        
    // (1) Comments at the beginning of the file are eliminated
    while(!modelsFile.eof() && (modelsFile.peek() == '#')) {
      getline(modelsFile,str);
      //cout << "SCARTO " << endl;
    }
    // (2) Read the number of contact
    if (modelsFile.eof()) {return 0;}
    getline(modelsFile,str,'\n');
    std::istringstream i_n(str);
    double x_n;
    i_n >> x_n;

    // (2) Read the type of the contact
    if (modelsFile.eof()) {return 0;}
    getline(modelsFile,str,'\n');
    
    // (3) Set h_ and r_
    if (modelsFile.eof()) {return 0;}
    getline(modelsFile,str,'\n');
    std::istringstream i_h(str);
    double x_h;
    i_h >> x_h;
    models_[idx].setH(x_h);
    if (modelsFile.eof()) {return 0;}
    getline(modelsFile,str,'\n');
    std::istringstream i_r(str);
    double x_r;
    i_r >> x_r;
    models_[idx].setR(x_r);

    int j = 0;
    while(!modelsFile.eof()) {
      getline(modelsFile,str,'\n');
      std::istringstream i(str);
      double x;
      i >> x;
      //cout << x << endl;
      models_[idx].addContact(x);
      j++;
    }
    if (j != x_n) {
      cout << "ERROR J " << j << " N " << x_n << endl;
      return 0;
    }
  }
  /* for (int i = 0; i < models_.size(); i++){ */
  /*   double min = models_[i].getMinDistance(); */
  /*   double max = models_[i].getMaxDistance(); */
  /*   double H = models_[i].getH(); */
  /*   double R = models_[i].getR(); */
  /*   cout  << models_[i].getName() << " " << max << " " <<  min  <<  " " <<  H  << " " <<  R << endl; */
  /* } */
  /* exit(0); */
};



#endif //ELECTRODE_MODEL_READER_H
