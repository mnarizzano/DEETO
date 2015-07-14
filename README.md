#DEETO
This is a simpler version of DDETO, made to be fully compliant with Slicer 3D

seeg electroDE  rEconstruction TOol:

This tool reconstructs the position of SEEG electrode contacts from a post-implant Cone-beam CT scan.

	USAGE: 
	
	   deeto  [-ct <string>] [-t/-e/-l/-h x y z] [-m -m n l r x1..xm]
	          [-h]
	
	Where 
	   -h       : shows the menu 
	   -t x y z : target point (x,y,z) are the coordinates 
   	   -e x y z : entry point (x,y,z) are the coordinates 
	   -l x y z : tail point (x,y,z) are the coordinates 
	   -h x y z : head point (x,y,z) are the coordinates 
	   -m n l r x1..xm :
	      	n = number of contacts 
                l = contact lenght  
                r = contact radius  
                x1..xm = contact distances, x1 is the distance between c1 and c2  
   	   -ct file :
              computer tomography file name 
	   -h        : This menu
  
      Notice that : 
     (*)  one between -e and -h is mandatory
     (*)  one between -t and -l is mandatory
     (*)  -ct is mandatory

##Software requirments
For builiding the tool you have to install some dependecies.


| Library       | Version      | URL |
| ------------- |:-------------|:----|
| Cmake         | 2.8          |[download](http://www.cmake.org/cmake/resources/software.html)
| ITK           | 4.3.1        |[download](http://www.itk.org/ITK/resources/software.html)

The version should be intended as a suggestion (ie we developped and
tested with these) but any minor revision of the above mentioned
library should work as well.

	
**For Debian- and RedHat-based distribution use *apt-get* or *yum* to
install the required libraries.** If you want to proceed with the
manual installation follow the steps below.

##MANUAL INSTALLATION

###Download and Install ITK


Download the latest ITK files from [ITK
website](http://www.itk.org/ITK/resources/software.html "ITK Project")
Extract all ITK files and enter in the unpacked directory. For an
easier cleanup process create a build directory where the code will be
compiled that can be removed later on when the entire process has
finished

	$ mkdir ./build && cd ./build
	
####Default configuration 
	$ cmake ../ ( assuming standard installation path and configurations)
####Advanced configuration
	$ ccmake ../ to call the ncursed configuration gui.

		Press c to configure the ITK setup. After configuration process press c again.
	
		Press g to generate and exit from configuration window.
	
Once the process has ended, and the Makefile has been created in your directory
		
	$ make 
	$ sudo make install

You can now clean the build directory, assuming that you are still within it, as **normal user** type

	$ rm -Rf *
	

###Build and Run

	
Build the project with cmake as we have done before with ITK 
	
	$ cmake CMakeLists.txt
	
	$ make
	
Run the generated executable file in directory bin
