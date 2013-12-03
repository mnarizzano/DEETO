#ifndef FCSV_WRITER
#define FCSV_WRITER

#include "Definitions.h"
#include "AbstractWriter.h"
#include <ostream>
#include <sstream>

/** 
  FCSVWriter class
  This class implements 3DSlicer fiducial list for reconstructed data.
  ATM, only v3 standard is supported. v4 support (which consists in a single file for fiducial point will be 
  handled in next stable release (since v4 support v3 std as retro-comp)
 */

class FCSVWriter: public AbstractWriter{

	public:
		/**@param filename
		  @param cmd*/
	    FCSVWriter(string filename, TCLAP::CmdLine& cmd){
			setFilename(filename); 
			setExtension("fcsv"); 
			color_[0]=0.4;
			color_[1]=1;
			color_[2]=1;
		}

		/** @param filename the output file name*/
	    FCSVWriter(string filename){setFilename(filename); setExtension("fcsv");}

		virtual ~FCSVWriter( void ){ };
	
		/** it writes down the recontructed data */
		int update();

	private:
		float color_[3];



};

int FCSVWriter::update() 
{
	
	checkFilename_();

	ofstream of;
	of.open(getFilename().c_str());
	assert(of.is_open());

	stringstream hdr;

	ClinicalFrame::ConstElectrodeIterator const_elec_it;

	ushort numPoints = 0;

	for(const_elec_it = begin(); const_elec_it != end(); const_elec_it++){
		numPoints += const_elec_it->getContactNumber();
	}
	
	// this is the header for FCSV as 3DSlicer v3 standard
	hdr<<"# Fiducial List file\n# version = 2\n# name ="<<getFilename()
		<<endl<<"# numPoints ="<< numPoints
		<<" \n# symbolScale = 2\n# symbolType = 13\n# visibility = 1\n# textScale = 1.2\n# color =0.4,1,1"
		<<endl<<"# selectedColor = 1,1,1\n# opacity = 1\n# ambient = 0\n# diffuse = 1\n# specular = 0"<<endl
		<<"# power = 1\n# locked = 1\n# numberingScheme = 0\n# columns = label,x,y,z,sel,vis";


	of<<hdr.str()<<endl;


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

	return 1;

}

#endif //FCSV_WRITER
