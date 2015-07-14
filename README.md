#DEETO
This is a simpler version of DDETO, made to be fully compliant with Slicer 3D

seeg electroDE  rEconstruction TOol:

This tool reconstructs the position of SEEG electrode contacts from a post-implant Cone-beam CT scan.

	USAGE: 
	
	   deeto  [-1] [-t <string>] [-o <string>] [-f <string>] [-c <string>] [--]
	          [--version] [-h]
	
	
	Where: 
	
	   -1,  --vtk-single-fout
	     Single output file for implant
	
	   -t <string>,  --o_type <string>
	      Output Type
	
	   -o <string>,  --out <string>
	     fname OUT
	
	   -f <string>,  --fid <string>
	     Fiducials File IN
	
	   -c <string>,  --ct <string>
	     CT File IN
	
	   --,  --ignore_rest
	     Ignores the rest of the labeled arguments following this flag.
	
	   --version
	     Displays version information and exits.
	
	   -h,  --help
	     Displays usage information and exits.

##Software requirments
For builiding the tool you have to install some dependecies.


| Library       | Version      | URL |
| ------------- |:-------------|:----|
| Cmake         | 2.8          |[download](http://www.cmake.org/cmake/resources/software.html)
| ITK           | 4.3.1        |[download](http://www.itk.org/ITK/resources/software.html)
| tclap         | 1.2.1        |[download](http://sourceforge.net/projects/tclap/files/).|
| VTK (**optional**)| 5.6      |[download](http://www.vtk.org/VTK/resources/software.html)

The version should be intended as a suggestion (ie we developped and tested with these) but any minor revision of the 
above mentioned library should work as well. 

	
**For Debian- and RedHat-based distribution use *apt-get* or *yum* to install the required libraries.**
If you want to proceed with the manual installation follow the steps below.

##MANUL INSTALLATION


###Download and install tclap

Download the latest version 1.2.1 from [tclap download page](http://sourceforge.net/projects/tclap/files/ "tclap Project"). 
Extract the archive and enter in the unpacked directory. 
The directory contains the autoconf and automake configuration files required for compilining and 
installing the library. It is sufficient to run within the unpacked directory:

	$ ./configure
	$ make && sudo make install
	
For problems with installation of this third-party library please refer to the sourceforge project page. 

###Download and Install CMake


Moreover, you need to download and install CMAKE in your computer.
Cmake is a cross-platform compiler and can be downloaded from 
[CMake website](http://www.cmake.org/cmake/resources/software.html "CMake Project")
	
Soon after the download has ended, extract the downloaded file and from the terminal
	

	$ ./configure
	$ make
	$ sudo make install

###Download and Install ITK


Download the latest ITK files from [ITK website](http://www.itk.org/ITK/resources/software.html "ITK Project")
Extract all ITK files and enter in the unpacked directory. For an easier cleanup process create a build directory
where the code will be compiled that can be removed later on when the entire process has finished

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
	

###Download and Install VTK (**optional**)


Download VTK from [VTK webpage](http://www.vtk.org/VTK/resources/software.html "VTK Project")
Then extract vtk files.
Goto vtk folder using Terminal and type
		
	$ ccmake .
	
After processing it will prompt a configuration option, press ‘c‘ to configure.
	
Edit its settings as required and press c, if generate option (g) is not present press c again.
	
Press g to generate.
	
	$ make
	$ sudo make install
	

###Build and Run

	
Build the project with cmake as we have done before with both ITK and VTK
	
	$ cmake CMakeLists.txt
	
	$ make
	
Run the generated executable file in directory bin
