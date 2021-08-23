$SearchAD = "nbb"
$Computers = Get-InactiveADComputers -SearchAD $SearchAD
if($computers -ne $null)
{
  $Cred = Get-Credential 
  foreach ($Computer in $Computers | Select-Object -Property Name, DistinguishedName) 
  {
    Remove-ADComputer -Identity $Computer.Name -Confirm -Credential $Cred
    Write-Host ('{0} was removed from AD.' -f $Computer.Name)
  }
}
else{
  Write-Host ('No Computers over 365 days found')
}

