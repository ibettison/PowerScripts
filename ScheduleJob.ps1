$Trigger = New-JobTrigger -AtStartUp
Register-ScheduledJob -name "Feature Update prompt" -FilePath "C:\powerscripts\featureupdate.ps1" -Trigger $Trigger