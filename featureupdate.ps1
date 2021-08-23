# add the required .NET assembly
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$UserResponse = [System.Windows.Forms.MessageBox]::Show('Windows 10 requires a feature update, would you like to open software centre and install this now?' , ' OS Update ' , 'YesNo')

if ($UserResponse -eq "Yes") 

{
  Start-Process C:\Windows\CCM\ClientUX\scclient.exe softwarecenter:Page=OSD
}

else

{
  [System.Windows.MessageBox]::Show('This update must be completed by April 12th at this point it will be forcefully deployed')
}

pause