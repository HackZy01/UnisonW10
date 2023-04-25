@echo off

if "%~1"=="" (
  echo Please drag and drop the AppxManifest.xml file onto this batch file to install it.
  pause
  exit
)

set "appx=%~1"

echo Installing %appx% ...

powershell -Command "Add-AppxPackage -Path ""%appx%"""

echo Installation complete!
pause
