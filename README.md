DEETO
=====

	seeg electroDE  rEconstruction TOol 

Software requirments
====================
	
	CMAKE, VTK, ITK, tclap
	
	For Debian- and RedHat-based distribution use apt-get or yum to install required libraries.


MANUL INSTALLATION
==================

Download and install tclap
==========================
	Download the latest version 1.2.1 from http://sourceforge.net/projects/tclap/files/. Extract the archive and enter in the unpacked directory. The directory contains the autoconf and automake configuration files required for compilining and installing the library. It is sufficient to run within the unpacked directory:
	$ ./configure
	$ make && make install
	
	For problems with installation of this third-party library please refer to the sourceforge project page. 

Download and Install CMake
==========================

	Moreover, you need to download and install CMAKE in your computer. Cmake is a cross-platform compiler and can be downloaded from http://www.cmake.org/cmake/resources/software.html
	
	Soon after the download has ended, extract the downloaded file and from the terminal
	
	$ ./configure
	
	$ make
	$ sudo make install
	
 

Download and Install ITK
========================

	Download the latest ITK files from ITK web site http://www.itk.org/ITK/resources/software.html.
	
	Extract all ITK files and enter in the unpacked directory.
		
	$ cmake . itk/InsightToolkit-4.3.1 ( assuming standard installation path and configurations)
	
	$ ccmake . .... to call the ncursed configuration gui.
	
		Press c to configure the ITK setup. After configuration process press c again.
	
		Press g to generate and exit from configuration window.
	
	Once the process has ended, and the Makefile has been created in your directory
		
	$ make 
	$ sudo make install
	
	

Download and Install VTK
========================

	Download VTK from VTK web page.
	
	URL: http://www.vtk.org/VTK/resources/software.html
	
	Then extract vtk and vtk data files.
	
	Goto vtk folder using Terminal and type
		
	ccmake .
	
	After processing it will prompt a configuration option, press ‘c‘ to configure.
	
	In some cases VTK data root may not be detected by the installer, then manually set the VTK data source as the extracted folder of VTK data as below.vtk
	
	Edit its settings as required and press c, if generate option (g) is not present press c again.
	
	Press g to generate.
	
	Type
		
	make
	
	, this process will take some considerable time (maybe hours).
	
	Finally type
		
	sudo make install
	
	for complete the installation.
Build and Run
=============

Build the project with cmake

cmake CMakeLists.txt

make

Run the generated executable file in directory bin
