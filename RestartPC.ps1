#remote restart
$Creds = Get-Credentials
Restart-Computer -ComputerName FMS-CIVI-D08 -Credential $Creds -Force