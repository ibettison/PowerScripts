$CurrentValue = [Environment]::GetEnvironmentVariable("PSModulePath", "Machine")
Write-Host $CurrentValue
$Creds = Get-Credential
[Environment]::SetEnvironmentVariable("PSModulePath", "$CurrentValue;\\campus\dept\crf\IT\PowerShellModuleRepo", "Machine") 