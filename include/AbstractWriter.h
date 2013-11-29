#ifndef ABSTRACT_WRITER
#define ABSTRACT_WRITER

#include "Definitions.h"
#include "ClinicalFrame.h"

/*!
  AbstractWriter class
*/
class AbstractWriter {

	public:

		/** const string getFilename() const */
		inline const string getFilename() const {return filename_;} 
		inline void getFilename(string filename) const {filename = filename_;}
		inline void setFilename(string filename){filename_ = filename;}

		inline void setExtension(string ext){extension_= ext;}

		inline const ClinicalFrame* getClinicalFrame( void) const{return clinicalframe_;}
		inline void setClinicalFrame(ClinicalFrame* cf){clinicalframe_= cf;}
		inline ClinicalFrame::ConstElectrodeIterator begin( void ) const{return clinicalframe_->begin();}
		inline ClinicalFrame::ConstElectrodeIterator end( void ) const{return clinicalframe_->end();}
		virtual int update() = 0;

	protected:
		/** checkFilename_() checks for proper file extension depending on which subclass has been 
		  istantiated*/
		void checkFilename_(void){
			string tmp;
			tmp = filename_.substr(0, filename_.length() - filename_.find_last_of(".")-1);
			filename_  = tmp.append(extension_);
			cout<<filename_<<endl;
		}

		/** AbstractWriter() */
		AbstractWriter(){ };

		/** ~AbstractWriter */
		virtual ~AbstractWriter(){ clinicalframe_ = NULL;}

	private:
		string extension_;
		string filename_;
		ClinicalFrame* clinicalframe_;
};
#endif //ABSTRACT_WRITER
