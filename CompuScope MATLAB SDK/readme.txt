RELEASE NOTES

*****************************************************
COMPUSCOPE SDK FOR MATLAB FOR WINDOWS
*****************************************************

The CompuScope SDK for MATLAB for Windows includes 
complete manuals in PDF form and several sample programs
that illustrate control and operation of Compuscope 
hardware in several operating modes.  The SDK is all
that is required to completely operate CompuSCope hardware 
from the MATLAB environment.


The SDK and driver architecture was designed in 
conjunction with the release of GaGe's new PCIe 
CompuScope cards and it's second-generation PCI 
CompuScope cards. Accordingly, the new SDK is 
recommended for future development as it exploits 
new features available with GaGe's CompuScope 
digitizers.

Please refer to the CompuScope SDK for MATLAB manual 
for the requirements for using this SDK and 
descriptions of the sample programs.


-----------------------------------------------------
ENHANCEMENTS FOR VERSION 5.02.06
-----------------------------------------------------

1) Minor bug fixes.


-----------------------------------------------------
KNOWN BUGS FOR VERSION 5.02.06
-----------------------------------------------------

1) Trigger delay should not be used with 
   GageStream2Disk.

2) When upgrading from a previous SDK version, the 
   startup.m file will get deleted from the 
   toolbox\local folder.  The paths included in this 
   file will have to be added manually for the 
   sample to work.

3) GageStream2Disk captures will not display 
   correctly in GageScope if the capture is larger 
   than the GageScope buffer size and has pre-trigger 
   data; pre-trigger data will not be aligned 
   correctly if align by trigger address is used.

4) The time stamp in the header of the Sig file 
   captured with GageStream2Disk will all have the 
   same value for all captures of a MulRec set.  
   This is not the case for individual capture though.


-----------------------------------------------------
ABOUT THE COMPUSCOPE SDK FOR MATLAB FOR WINDOWS
-----------------------------------------------------

NOTE: When writing an M-file for the CompuScope SDK 
      for MATLAB, do not use the MATLAB "clear all" 
      function.  This will clear out all function 
      pointers and the dlls will have to be 
      reinitialized.  Use the "clear" function 
      instead.

GaGe's CompuScope SDK for MATLAB for Windows allows 
you to control one or more CompuScope cards from the 
MATLAB environment.

The CompuScope Win XP/Vista/Win7/Win8 Drivers Version 
5.xx.xx supports CompuScopes including: CobraMax 
CompuScope (CScdG8 & CSEcdG8), Cobra CompuScope 
(CSXYG8 & CSEXYG8), BASE-8 cards(CScdG8), CS1250X, 
Eon CompuScope (CSCDG12), Razor and Oscar CompuScopes
(CS16XYY & CSE16XYY), Octopus CompuScope (CS8XXX & 
CSE8XXX), and CSUSB CompuScope.

Please note that support for CS12100, CS1220, CS12400, 
CS1250, CS14105, CS14100, CS14100C, CS14200, CS1450, 
CS1602, CS1610, CS1610C, CS3200, CS3200C, CS82G, 
CS82G-1GHz, CS82GC, CS82GC-1GHz, and CS8500 CompuScopes
has been discontinued in the version 5.xx.xx CompuScope 
driver.  Please visit the GaGe website 
(www.gage-applied.com/Support) to download the 4.82.22 
CompuScope driver that was the last version which 
supported these CompuScopes.


-----------------------------------------------------
WHAT TO LOOK OUT FOR WHEN INSTALLING THE COMPUSCOPE 
SDK FOR MATLAB FOR WINDOWS
-----------------------------------------------------

1) You MUST install the CompuScope Drivers before 
   attempting to use the CompuScope SDK for MATLAB.  
   Without the proper drivers, the CompuScope SDK for 
   MATLAB will not function properly.  See the Driver 
   Installation section of the Startup Guide for 
   instructions on installing the CompuScope Windows
   Drivers and the CompuScope SDK for MATLAB for 
   Windows.

2) The installation will fail if the installer is not 
   an Administrator.

3) Please note that you will be asked to enter a 
   software key during the SDK installation process.  
   This software key is provided upon purchase of the 
   SDK.

4) We recommend that you use the default installation 
   directory; however, you will be prompted to change 
   it if you wish.

5) If during the installation of the SDK you receive 
   a message stating that the MATLAB path could not 
   be modified to include the CompuScope MATLAB SDK 
   path, then you will have to do one of the 
   following:

   a) Copy the contents of addpath.m from the SDK's 
      Main directory to your MATLAB 
      directory\toolbox\local\startup.m, if this file 
      currently exists or else create the file with 
      the contents of addpath.m.

   b) Run addpath.m from the SDK's Main directory 
      every time you load up MATLAB.

   c) Add the path of the three SDK directories (Adv, 
      CsMl, and Main) through the "Set Path" function 
      under "File".

See your CompuScope SDK for MATLAB User's Guide for 
more details on using the CompuScope SDK for MATLAB.



=====================================================
Comments and suggestions can be addressed to:

Project Manager - CompuScope SDK for MATLAB for Windows
Gage Applied Technologies


In North America:
Tel:    800-567-GAGE
Fax:    800-780-8411

Outside North America:
Tel:    +1-514-633-7447
Fax:    +1-514-633-0770

E-mail:   prodinfo@gage-applied.com
Web site: www.gage-applied.com
