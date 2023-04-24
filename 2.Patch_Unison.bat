cd "%1"
del AppxSignature.p7x AppxBlockMap.xml [Content_Types].xml
rmdir -r AppxMetadata
powershell -Command "(gc AppxManifest.xml) -replace '10.0.22621.0','10.0.19045.0' | Out-File "AppxManifest.xml"
xcopy Assets "%1"\Assets\