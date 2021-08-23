function Get-SelectedUserId
{
	<#
	.SYNOPSIS
	Receive a user (Will search for all matches) uses GridView to select the user
	.DESCRIPTION
	Receive a user (Will search for all matches) uses GridView to select the user returns the userId of the selected User.
	.EXAMPLE
	Get-SelectedUserId - UserToCopy
	#>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory, Position=0)]
		[String]
		$UserToCopy
		
	)
	$userFind = (Get-ADUser -Filter {DisplayName -Like $UserToCopy} -Properties * | Select-Object SamAccountName, GivenName, Surname, Description)
	$Idx =0
	$userId = $(foreach ($item in $userFind){
			$item | Select-Object -Property @{l='IDX'
			e={$Idx}}, SamAccountName, GivenName, SurName, Description
	$Idx++	}) |
	Out-GridView -Title 'Select the User Id to use' -OutputMode Single |
	ForEach-Object { $userFind[$_.IDX] }
	return $userId
}

$Creds = ''
Clear-Host
#Type the user name to search for, accepts patial matches
$UserToCopy = Read-Host -Prompt 'Type the user to copy from'
Write-Host 'Please Wait! Searching for matching users may take a little while...'
# Exits if the string is empty
if(-not [string]::IsNullOrEmpty($UserToCopy)) 
	{
		try
		{
			$UserToCopy = ('*{0}*' -f $UserToCopy)
			#Call function Get-SelectedUser Id to get the id of the user to copy the Groups from
			$UserId = Get-SelectedUserId -UserToCopy $UserToCopy
			if([string]::IsNullOrEmpty($UserId)) {
				throw('No User Id selected.')
			}
		}
		catch
		{
			Write-Verbose -Message ("`nERROR: {0}" -f $_)
		}
		# get the groups that reqire copying from the selected Id
		$CopiedGroups = Get-GroupMembership -ADUserId $UserId.SamAccountName
		# Enter a user Id to copy the groups to
		$UserToCopyTo = Read-Host -Prompt 'Type the user to copy the AD Groups To'
		if( -not [string]::IsNullOrEmpty($UserToCopyTo)) {
      try
      {
        $UserToCopyTo = ('*{0}*' -f $UserToCopyTo)
        # use the entered user name to find the userid of the user to copy the groups to
        $UserId = Get-SelectedUserId -UserToCopy $UserToCopyTo
        if([string]::IsNullOrEmpty($UserId)) {
          throw('No User Id selected.')
        }
      }
      catch
      {
        Write-Error -Message ("`nERROR: {0}" -f $_)
        EXIT
      }
			# Enter credentials to allow the AD changes
			if([string]::IsNullOrEmpty($Creds))
			{
				$Creds = Get-Credential
			}
			# Loop through the $CopiedGroups object to add the groups to the selected user
			foreach ($item in $CopiedGroups)
			{
				Write-Host ('Adding Group {0} to user {1}' -f $item.Name, $userId.SamAccountName)
				Add-ADGroupMember -Identity $item.Name -Members $userId.SamAccountName -Credential $Creds
			}
			
		
		}

	}