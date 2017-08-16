function Find-OULocations
{
  <#
      .SYNOPSIS
      Short Description
      .DESCRIPTION
      Detailed Description
      .EXAMPLE
      Find-OULocations
      explains how to use the command
      can be multiple lines
      .EXAMPLE
      Find-OULocations
      another example
      can have as many examples as you like
  #>
  param
  (
    [Parameter(Mandatory, Position=0)]
    [System.String]
    $Prompt
  )
  $level = Select-ADOU -Title $Prompt -ShowContainers -SingleDomain
  return $level
}
$sourceOU = Find-OULocations -Prompt 'Select the Top Level OU you want to unprotect from deletion' 
  if([string]::IsNullOrEmpty($sourceOU))
  {
    throw("No location selected.")
  }
  $OUs = Get-ADOrganizationalUnit -SearchBase $sourceOU.OUDN -Filter * -Searchscope Subtree
  foreach ($item in $OUs)
  {
    Set-ADObject $item -ProtectedFromAccidentalDeletion:$false
    write-host ("{0} had it's protection from deletion - Removed" -f $item.Name)
  }
  