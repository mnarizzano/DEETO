#ifndef CMD_PARSER_H
#define CMD_PARSER_H

#include <Definitions.h>

class CmdParser {
 public:
  CmdParser( ){
    _head   = MAX_VALUE;
    _tail   = MAX_VALUE;
    _entry  = MAX_VALUE;
    _target = MAX_VALUE;
    _fileCT = NULL;
    _contactDiameter = 0.8; // mm da cambiare?
    _contactLenght = 2.5;   // mm da cambiare? 
    _threshold = 0.0;
  }
  
  ~CmdParser( ){}
  
  void setHead(PhysicalPointType h) {_head = h; }
  void setEntry(PhysicalPointType e) {_entry = e;}
  void setTail(PhysicalPointType t) {_tail = t;}
  void setTarget(PhysicalPointType t) {_target = t;}
  void setContactDiameter(float cd) { _contactDiameter = cd;}
  void setContactLenght(float cl) { _contactLenght = cl;}  
  float setThreshold(float t) { return _threshold = t;}
  void setModel(vector< float > m) { 
    for (unsigned int i = 0; i < m.size(); i++){
      _model[i] = m[i];
    }
  }
  
  PhysicalPointType getHead( ) { return _head;}
  PhysicalPointType getEntry( ) { return _entry;}
  PhysicalPointType getTail( ) { return _tail;}
  PhysicalPointType getTarget( ) { return _target;}
  char* getFileCT( ) {return _fileCT;}
  float getContactDiameter( ) { return _contactDiameter;}
  float getContactLenght( ) { return _contactLenght;}
  float getThreshold( ) { return _threshold;}
  vector< float > getModel() { return _model;} 


  int parse(int argc, char **argv) { 
    char *p; // as check for reading the number
    double number;
    if (argc <= 1) { return -1; }
    for (unsigned int i=1; i< argc; i++) {
      /// [TODO] handle help
      /* if (strcmp(argv[i],"-h") == 0) { */
      /* 	printCmdLine(argv[0]); */
      /* 	return 0; */
      /* } else  */
      if (strcmp(argv[i],"-ct") == 0) {
	_fileCT = argv[i+1];
	i = i + 1;
      }else if (strcmp(argv[i],"-s") == 0) {
	if(i+1 >= argc) { return -1; } // GESTIRE ERRORE
	number = strtod(argv[i+1],&p);
	if (*p) return -1;
	_threshold = number;
	i = i + 1;
      } else if (strcmp(argv[i],"-h") == 0) {
	if(i+3 >= argc) { return -1; } // GESTIRE ERRORE
	number = strtod(argv[i+1],&p);
	if (*p) return -1;
	_head[0] = number;
	number = strtod(argv[i+2],&p);
	if (*p) return -1;
	_head[1] = number;
	number = strtod(argv[i+3],&p);
	if (*p) return -1;
	_head[2] = number;
	i = i + 3;
      }else if (strcmp(argv[i],"-l") == 0) {
	if(i+3 >= argc) { return -1; } // GESTIRE ERRORE
	number = strtod(argv[i+1],&p);
	if (*p) return -1;
	_tail[0] = number;
	number = strtod(argv[i+2],&p);
	if (*p) return -1;
	_tail[1] = number;
	number = strtod(argv[i+3],&p);
	if (*p) return -1;
	_tail[2] = number;
	i = i + 3;
      }else if (strcmp(argv[i],"-e") == 0) {
	if(i+3 >= argc) { return -1; } // GESTIRE ERRORE
	number = strtod(argv[i+1],&p);
	if (*p) return -1;
	_entry[0] = number;
	number = strtod(argv[i+2],&p);
	if (*p) return -1;
	_entry[1] = number;
	number = strtod(argv[i+3],&p);
	if (*p) return -1;
	_entry[2] = number;
	i = i + 3;
      }else if (strcmp(argv[i],"-t") == 0) {
	if(i+3 >= argc) { return -1; } // GESTIRE ERRORE
	number = strtod(argv[i+1],&p);
	if (*p) return -1;
	_target[0] = number;
	number = strtod(argv[i+2],&p);
	if (*p) return -1;
	_target[1] = number;
	number = strtod(argv[i+3],&p);
	if (*p) return -1;
	_target[2] = number;
	i = i + 3;
      }else if (strcmp(argv[i],"-m") == 0) {
	if(i+1 >= argc) { return -1; } // GESTIRE ERRORE
	i = i + 1;
	unsigned int j=i;
	for (; j < argc; j++) {
	  number = strtod(argv[j],&p);
	  if (*p) {
	    // conversion failed since argv[i] was not a number
	    break;
	  } else {
	    _model.push_back(number);
	  }
	}
	i = j - 1;
      } else {
	return -1;
      }
    }
    return 0;
  }

  void printData( ) {
    cout << "H " << _head << endl;
    cout << "L " << _tail << endl;
    cout << "E " << _entry << endl;
    cout << "T " << _target << endl;
    if (_fileCT != NULL) { cout << "FILE " << _fileCT << endl;}
    cout << "CD " << _contactDiameter << endl;
    cout << "CL " << _contactLenght << endl;
    cout << "M ";
    for(unsigned int i=0; i < _model.size(); i++) {
      cout << "[" << _model[i] << "],";
    }
    cout << endl;
  }

  
  void printCmdLine(char *argv){
    cout << "usage :" << endl;
    cout << argv << "  <options>" << endl;
    cout << "options:" << endl;
    cout << "   -h " << endl;
    cout << "            : shows the menu " << endl;
    cout << "   -s t " << endl;
    cout << "            : set the threshold. 0.0 default" << endl;
    cout << "   -t x y z " << endl;
    cout << "            : target point (x,y,z) are the coordinates " << endl;
    cout << "   -e x y z " << endl;
    cout << "            : entry point (x,y,z) are the coordinates " << endl;
    cout << "   -l x y z " << endl;
    cout << "            : tail point (x,y,z) are the coordinates " << endl;
    cout << "   -h x y z " << endl;
    cout << "            : head point (x,y,z) are the coordinates " << endl;
    cout << "   -m n l r x1..xm" << endl;
    cout << "            : n = number of contacts " << endl;
    cout << "              l = contact lenght  " << endl; 
    cout << "              r = contact radius  " << endl;
    cout << "              x1..xm = contact distances, x1 is the distance between c1 and c2  " << endl;
    cout << "   -ct file :" << endl;
    cout << "              computer tomography file name " << endl << endl;

    cout << " Notice that : " << endl;
    cout << " (*)  one between -e and -h is mandatory" << endl;
    cout << " (*)  one between -t and -l is mandatory" << endl;
    cout << " (*)  -ct is mandatory" << endl;
  }

  
 private:
  char* _fileCT;
  PhysicalPointType  _head;
  PhysicalPointType  _tail;
  PhysicalPointType  _target;
  PhysicalPointType  _entry;
  float _contactDiameter;
  float _contactLenght;
  float _threshold;
  vector< float > _model;
  
  int _result;
  
};

#endif
