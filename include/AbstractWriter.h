#ifndef ABSTRACT_WRITER
#define ABSTRACT_WRITER

#include "Definitions.h"
#include "ClinicalFrame.h"

/*!
  AbstractWriter class
  This class is the base class for each writer. It takes care of filename consistency and it holds the ClinicalFrame pointer.
*/

class AbstractWriter {

	public:

		inline const string getFilename() const {return filename_;} 
		inline void getFilename(string filename) const {filename = filename_;}
		inline void setFilename(string filename){filename_ = filename;}
		inline void setExtension(string ext){extension_= ext;}
		inline const ClinicalFrame* getClinicalFrame( void) const{return clinicalframe_;}
		inline void setClinicalFrame(ClinicalFrame* cf){clinicalframe_= cf;}

		/** returns the head of ConstElectrodeIterator to navigate the ClinicalFrame implant details*/
		inline ClinicalFrame::ConstElectrodeIterator begin( void ) const{return clinicalframe_->begin();}
		/** returns the tail fo ConstElectrodeIterator */
		inline ClinicalFrame::ConstElectrodeIterator end( void ) const{return clinicalframe_->end();}

		/** pure virtual method that each child should implement depending on file formats */
		virtual int update() = 0;

	protected:
		/** appends correct extension to filename depending on which subclass has been 
		  istantiated*/
		void checkFilename_(void){
			string tmp;
			tmp = filename_.substr(0, filename_.find_last_of(".")+1);
			filename_  = tmp.append(extension_);
		}

		/** Purposely proteced since it is supposed to be istantiated only by its child*/
		AbstractWriter(){ };

		/** It sets the ClinicalFrame* to NULL upon call */
		virtual ~AbstractWriter(){ clinicalframe_ = NULL;}

	private:
		string extension_; /** string that saves the filename extension for checking consistency */
		string filename_; /** string that holds the actual filename + extension (after correction) */
		ClinicalFrame* clinicalframe_; /** pointer to clinical frame and reconstructed implant points */
};
#endif //ABSTRACT_WRITER
