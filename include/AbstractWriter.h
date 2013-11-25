#ifndef ABSTRACT_WRITER
#define ABSTRACT_WRITER

#include "Definitions.h"
#include "ClinicalFrame.h"

class AbstractWriter {

	public:

		inline const string* getFilename() const {return filename_;} 
		inline void getFilename(const string* filename) const {filename = filename_;}
		inline void setFilename(string* filename){filename_ = filename;}
		inline void setClinicalFrame(ClinicalFrame* cf){clinicalframe_= cf;}
		inline ClinicalFrame::ConstElectrodeIterator begin( void ) const{return clinicalframe_->begin();}
		inline ClinicalFrame::ConstElectrodeIterator end( void ) const{return clinicalframe_->end();}
		virtual void update() const = 0;


	protected:
		AbstractWriter(){ };
		virtual ~AbstractWriter(){ 
			filename_= NULL; 
			clinicalframe_ = NULL;
		}

	private:
		string* filename_;
		ClinicalFrame* clinicalframe_;
};
#endif //ABSTRACT_WRITER
