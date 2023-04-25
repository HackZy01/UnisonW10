@echo off
setlocal

set directory=%~1
if not defined directory (
    echo Please drag and drop the WebPhonePackaging folder
    exit /b 1
)

pushd %directory% || (
    echo Could not change directory to %directory%.
    exit /b 1
)

del /q AppxSignature.p7x AppxBlockMap.xml [Content_Types].xml

if exist AppxMetadata (
    rmdir /q /s AppxMetadata
)

powershell -Command "(gc AppxManifest.xml) -replace '10.0.22621.0','10.0.15063.0' | Out-File “AppxManifest.xml”

rem log the script execution
set logFile=C:\Logs\Patch_Log.TXT
echo %date% %time% - Modifed AppxManifest.xml in %directory%. >> %logFile%

popd
