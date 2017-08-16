$fileExec = '& \\crf-psrv2\DiscoveryTool\Intel-SA-00075-console.exe'
Start-Process powershell -ArgumentList "$fileExec -n -f -p \\crf-psrv2\DiscoveryFiles"