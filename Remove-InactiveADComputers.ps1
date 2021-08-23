function Remove-InactiveADComputers
{
  <#
    .SYNOPSIS
    This function removes any Computers that have not been active for 365 days
    .DESCRIPTION
    This function checks the activity of Computers in an Active Directory Organisational Unit and removes them from AD
    .EXAMPLE
    Remove-InactiveADComputers - SearchAD CRF
    Add the parameter for the top level OU and the computers found are deleted.
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory, Position=0)]
    [System.String]
    $SearchAD
  )
  
  $Computers = Get-InactiveADComputers -SearchAD $SearchAD
  $Cred = Get-Credential 
  foreach ($Computer in $Computers | Select-Object -Property Name, DistinguishedName) 
  {
    Remove-ADComputer -Identity $Computer.Name -Confirm -Credential $Cred
  }
}

