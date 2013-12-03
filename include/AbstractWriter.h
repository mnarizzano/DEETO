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

		/** returns the filename */
		inline const string getFilename() const {return filename_;} 
		/** returns the filename */
		inline void getFilename(string filename) const {filename = filename_;}
		/** setter for filename */
		inline void setFilename(string filename){filename_ = filename;}
		/** setter method for file extension*/
		inline void setExtension(string ext){extension_= ext;}
		/** getter for clinical frame pointer */
		inline const ClinicalFrame* getClinicalFrame( void) const{return clinicalframe_;}
		/** setter method for ClinicalFrame */
		inline void setClinicalFrame(ClinicalFrame* cf){clinicalframe_= cf;}
		/** returns the head of ConstElectrodeIterator to navigate the ClinicalFrame implant details*/
		inline ClinicalFrame::ConstElectrodeIterator begin( void ) const{return clinicalframe_->begin();}
		/** returns the tail fo ConstElectrodeIterator */
		inline ClinicalFrame::ConstElectrodeIterator end( void ) const{return clinicalframe_->end();}
		virtual int update() = 0;

	protected:
		/** checkFilename_() checks for proper file extension depending on which subclass has been 
		  istantiated*/
		void checkFilename_(void){
			string tmp;
			tmp = filename_.substr(0, filename_.find_last_of(".")+1);
			filename_  = tmp.append(extension_);
		}

		/** Purposely proteced since it is istantiated only by its child*/
		AbstractWriter(){ };

		/** It sets the ClinicalFrame* to NULL upon call */
		virtual ~AbstractWriter(){ clinicalframe_ = NULL;}

	private:
		string extension_;
		string filename_;
		ClinicalFrame* clinicalframe_;
};
#endif //ABSTRACT_WRITER
