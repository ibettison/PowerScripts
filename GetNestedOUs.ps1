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

function Set-GPOPerLink
{
  <#
      .SYNOPSIS
      Short Description
      .DESCRIPTION
      Detailed Description
      .EXAMPLE
      Set-GPOPerLink
      explains how to use the command
      can be multiple lines
      .EXAMPLE
      Set-GPOPerLink
      another example
      can have as many examples as you like
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory, Position=0)]
    [Object]
    $linkedGPOs,
    [Parameter(Mandatory, Position=0)]
    [Object]
    $path
  )
  
  $GpoCount=0
  foreach ($gpo in $linkedGPOs.GpoLinks | Select-Object -Property GpoId, Enabled, DisplayName )
  {
    
    $Enabled = "No"
    if ($gpo.Enabled)
    {
      $Enabled = "Yes"
    }
    $GPOId = $gpo.GpoId
    $Permissions = Get-GPPermission -Guid $GPOId -All
    $permissionSet = $Permissions | Where-Object {$_.Trustee.Name -eq "CRF_Administrators"}
    if ($permissionSet -eq $null)
    {
      # set the permission for CRF_Administrators on the GPO
      # Set-GPPermission -Guid $GPOId -PermissionLevel GpoEditDeleteModifySecurity -TargetName 'CRF_Administrators' -TargetType Group
      Write-Verbose ("The GPO - {0} does not have permission for CRF_Administrators`n" -f $gpo.DisplayName )
    }
    $gpo.DisplayName+"`n"
    New-GPLink -Guid $GPOId -Target $path -LinkEnabled $Enabled	
    $GpoCount ++
  }
  Write-Host ("There were {0} GPOs added to {1}`n" -f $GpoCount, $path)
}


Clear-Host
try
{
	# Content

	$sourceOU = Find-OULocations -Prompt 'Add the OU name to copy the GPOs FROM' 
	if([string]::IsNullOrEmpty($sourceOU))
	{
		throw("No location to copy from was entered.")
	}
	$destinationOU = Find-OULocations -Prompt 'Add the OU name to copy the GPOs TO '
	if([string]::IsNullOrEmpty($destinationOU))
	{
		throw("No location to copy to was entered.")
	}
	if([string]::IsNullOrEmpty($Creds))
	{
		$Creds = Get-Credential
	}
	$adPath = $sourceOU.OUDN
	$OUsToCopy = Get-ADOrganizationalUnit -SearchBase $sourceOU.OUDN -Filter * -Searchscope Subtree
	foreach ($item in $OUsToCopy)
	{
    if ($item.name -like $OUsToCopy.name[0])
    {
      # Do Nothing
      $replacement = $item.DistinguishedName.Replace($adPath, $destinationOU.OUDN)
      $path = $replacement
    
      $linkedGPOs = (Get-GPInheritance -Target $sourceOU.OUDN)
      Set-GPOPerLink -linkedGPOs $linkedGPOs -path $path    
    }else{
      $replacement = $item.DistinguishedName.Replace($adPath, $destinationOU.OUDN)
      $path = $replacement.TrimStart($replacement.Split(",")[0]).trim(",")
      $linkedGPOs = (Get-GPInheritance -Target $item.DistinguishedName)
      New-ADOrganizationalUnit -Name $item.Name -Path $path -Instance $item -Credential $Creds
      Set-GPOPerLink -linkedGPOs $linkedGPOs -path $replacement
    }
  
	}

}
catch
{
  "Error was $_"
  $line = $_.InvocationInfo.ScriptLineNumber
  "Error was in Line $line"
}

