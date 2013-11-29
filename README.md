DEETO
=====

seeg electroDE  rEconstruction TOol 

Software requirments
====================

CMAKE, VTK, ITK

For Debian- and RedHat-based distribution use apt-get or yum to install required libraries.


MANUL INSTALLATION
==================

Download and Install CMake
==========================

As first step you need to download and install CMAKE in your computer. Cmake can download from following URL,

http://www.cmake.org/cmake/resources/software.html

Extract the downloaded file. Then go to the extracted folder using Terminal.

Next type
	
./configure

on terminal.

After running configuration type
	
make

in the terminal, after its make process type
	
sudo make install

If you typed
	
make install

instead of
	
sudo make install

at the end of the process it will show an error of writing permission to the disk.  After this process installation of CMake is complete.

 
Download and Install VTK
========================

Download VTK and VTK data from VTK web page.

URL: http://www.vtk.org/VTK/resources/software.html

Then extract vtk and vtk data files.

Goto vtk folder using Terminal and type
	
ccmake .

After processing it will prompt a configuration option, press ‘c‘ to configure.

In some cases VTK data root may not be detected by the installer, then manually set the VTK data source as the extracted folder of VTK_data as below.vtk_3

Edit its settings as required and press c, if generate option (g) is not present press c again.

Press g to generate.

Type
	
make

, this process will take some considerable time (maybe hours).

Finally type
	
sudo make install

for complete the installation.


Download and Install ITK
========================

This process is also similar to installing VTK. Following are the steps for installing ITK on Ubuntu.

Download ITK files from ITK web site.

Extract all ITK files.

Create folder named ITK.

Go to ITK folder from Terminal.

Type
	
ccmake . /home/thilina/vtk_itk/InsightToolkit-4.3.1 (location where ITK file extracted)

Press c to configure the ITK setup. After configuration process press c again.

Press g to generate and exit from configuration window.

Type
	
make

for make process. Then type
	
sudo make install

For final step of installation. Then ITK installation is complete.


///////////////////////////////////////////////////////////////////////////////
Build and Run
///////////////////////////////////////////////////////////////////////////////

Build the project with cmake

cmake CMakeLists.txt

make

Run the generated exe in directory bin

