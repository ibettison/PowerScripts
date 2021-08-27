#Get-WmiObject -Namespace ROOT\CIMV2 -Class Win32_Product -Computer FMS-CIVI-D51
$credentials = Get-Credential
Invoke-Command -ComputerName FMS-CIVI-D51 -Authentication Credssp -Credential $credentials -ScriptBlock {Get-WmiObject win32_SystemEnclosure}
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate