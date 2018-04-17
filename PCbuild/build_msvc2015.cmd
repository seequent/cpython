@echo off
rem Building Python 2.7.13 with Visual Studio 2015

rem Set Visual studio compiler
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin\amd64\vcvars64.bat"

rem This needs a running version of SVN.
set PATH=%PATH%;C:\Program Files (x86)\Subversion\bin;c:\Program Files\Git\usr\bin;c:\Program Files\7-Zip;C:\Program Files\TortoiseHg;C:\Program Files (x86)\Windows IEAK 11\tools\

call get_externals.bat

rem Patch externals
pushd ..
patch.exe -s -p1  < pcbuild\build_msvc2015_externals.patch
popd

rem Build the binaries
rem Release version including all externals
call build.bat -e -m -k -p x64 "/p:PlatformToolset=v140"
rem Debug version including all externals
call build.bat -d -e -m -k -p x64 "/p:PlatformToolset=v140"

rem Build the icon dll
pushd ..\PC
nmake /f icons.mak
popd

rem Fake the help file
mkdir ..\Doc\build\htmlhelp
pushd ..\Doc\build\htmlhelp
copy NUL python2713.chm
popd

rem Build the msi itself
pushd ..\Tools\msi
del *.msi
nmake /f msisupport.mak
set PCBUILD=PCBuild\amd64
set MSVCR=140
rem This should be an environment variable
rem requires win32 package to be installed
"C:\Python-2.7.12-amd64\python.exe" msi.py
copy python-2.7.*.amd64.msi ..\..\..
copy python-2.7.*.amd64-pdb.zip ..\..\..
popd

rem Run all Regression tests
pushd  amd64
python.exe -m test.regrtest
popd

