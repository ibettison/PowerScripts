$Action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-NoLogo -WindowStyle hidden -file C:\powerscripts\featureupdate.ps1"
$Trigger = New-ScheduledTaskTrigger -AtLogon
$Principal = New-ScheduledTaskPrincipal -GroupID "Authenticated Users"
Register-ScheduledTask -Action $Action  -Trigger $Trigger -TaskName "Feature Update prompt" -Principal $Principal -Description "Displays the feature update prompt on login"
