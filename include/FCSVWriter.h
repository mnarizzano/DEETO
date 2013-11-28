#ifndef FCSV_WRITER
#define FCSV_WRITER

#include "Definitions.h"
#include "AbstractWriter.h"
#include <ostream>

class FCSVWriter: public AbstractWriter{

	public:
	    FCSVWriter(string filename){setFilename(filename); setExtension("fcsv");}

		virtual ~FCSVWriter( void ){ };

		void update() ;

};
#endif //FCSV_WRITER


void FCSVWriter::update() 
{
	// open file for writing 
	// handle the exception for permission denied 
	// no space left on device 
	
	checkFilename_();

	cout<<getFilename()<<endl;

	ofstream of;
	of.open(getFilename().c_str());
	assert(of.is_open());

	ClinicalFrame::ConstElectrodeIterator const_elec_it;
	try{
			// for each electorde in clinical frame
			for(const_elec_it = begin(); const_elec_it != end(); const_elec_it++){
				// write down all the contacts that belongs to one electrode
				of<<(*const_elec_it);
			}
			
			of.close();
	}
	catch(ostream::failure e){
		// add logging information
		cerr<<" "<<endl;
	}

}

