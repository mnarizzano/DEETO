#DEETO


seeg electroDE  rEconstruction TOol:

This tool reconstructs the position of SEEG electrode contacts from a post-implant Cone-beam CT scan.

USAGE: 

   ./deeto  [-r] [-m <string>] [-d <string>] [-t <string>] [-o <string>]
            [-f <string>] [-c <string>] [--] [--version] [-h]


Where: 

   -r,  --noref
     File fcsv is assumed in Ref, this flag on allow the file fcsv to be in
     centered

   -m <string>,  --model_types <string>
      Models Electrode Types

   -d <string>,  --db_name <string>
      Data Base Name for the Electrode Type

   -t <string>,  --type <string>
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

# 

This branch is for testing the feature of having different model for
the electrodes.  So if you have a subject (s1) containing 10
electrodes, half of them with default model and half of them with
cinque model(contatcs are grouped in group of 5) you need at least
three files:

1) db-files/default-db.csv a sort of databases. In each line is shown
   the name of the model separated by comma and the path where you can
   find the model structure.

   In more details this file is structured as follow:

   # name of the electrode model, path to the file containing the electrode model information 
   default,/home/massimo/Tools/mytools/deeto/db-files/default-electrode-model.csv
   cinque,/home/massimo/Tools/mytools/deeto/db-files/cinque-electrode-model.csv

2) The electrode model information, i.e. the file listed in the db files.
   The file is structured as follow:
   # number of contacts  
   # contact type (0 = CYLINDER; 1 = cube; 2 = rectangular)
   # length(mm)
   # diameter(mm)
   # distances beetween contacts(first always 0.0)
   # notice that distance between the current contact and the previous
   Please take a look at db-files/default-electrode-model.csv
   

3) subject-model-electrode.txt, a file where it is for each electrode
   in the file fcsv is reported the model of the electrode. If an
   electrode is not listed, it is assumed the default electrode model
   (db-files/default-electrode-model.csv)

   The file is structured as follow:
   # electrode_name,model_name
   
   take a look at db-files/example-of-subject-model-electrode.txt