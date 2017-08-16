function Get-GroupMembers
{
	<#
			.SYNOPSIS
			Allows a search for a partial text to match AD Group and list members in the group
			.DESCRIPTION
			Search to find the list of Active Directory Groups matching the partial string parameter -ADGroup then displays the members of that group 
			.EXAMPLE
			Get-GroupMembers -ADGroup CRF
			This will search for Active Directory Group matching the partial text passed using the -ADGroup parameter
	#>
	param
	(
		[Parameter(Mandatory, Position=0)]
		[String]
		$ADGroup
	)
	
	try 
	{
		if([string]::IsNullOrEmpty($ADGroup))
		{
			throw 'Cannot search on NULL data.'
		}
		# adds asterisks to the passed parameter to pass into the filter option in the scriptBlock below.		
		$ADGroup = '*' + $ADGroup + '*'
		# Start a job to list all of the Active Directory Groups matching the parameter (No output)
		Start-Job -Name getList -ScriptBlock {param([Parameter(Mandatory,HelpMessage='Enter the Partial Group')][String]$pGroup) Get-ADGroup -Filter {Name -like $pGroup} -Properties * | Select-Object -Property Name, Description} -ArgumentList $ADGroup | Out-Null
		# wait for the job to finish (No output)
		Wait-Job -Name getList | Out-Null
		# It is now safe to receive the output from the job.
		$groupList = Receive-Job -Name getList
		# has the search returned any information
		if([string]::IsNullOrEmpty($groupList)) 
		{
			throw 'Group was not found.'
		}
		else
		{
			# setup a grid view to select the Group Single selection
			$Idx =1
			$group = $(foreach ($item in $groupList){
					$item | Select-Object -Property @{l='IDX'
					e={$Idx}}, Name
			$Idx++	}) |
			Out-GridView -Title 'Select one of the AD Groups to use' -OutputMode Single |
			ForEach-Object { $groupList[$_.IDX] }
		}
	}
	catch
	{
		Write-Host ('ERROR : {0}' -f $_)
		Exit
	}
	# Check if the group exists and was selected
	if(-not [string]::IsNullOrEmpty($group)) 
	{
		try
		{
			# get the list of members within the group
			$members = Get-ADGroupMember -identity $group.Name -Recursive
		}
		catch 
		{        
			Write-Host -Message ("`nThe group name may have contained a typo as I did not find it. `n`nERROR - {0}" -f $_)
			Exit
		}
		# Are there any members
		if(-not [string]::IsNullOrEmpty($members))
		{
			$listUsers= @{}
			$arrayCount=0
			Write-Host "`nDisplaying the members of this group: " 
			# loop through the members of the group               
			foreach( $member in $members )
			{
				# Create an array of the members
				$listUsers[$arrayCount++] = Get-ADUser -Identity $member.SamAccountName | Select-Object -Property name, GivenName, Surname
			}
			# Display the members to the console
			foreach($user in $listUsers.Values){
				Write-Host $user.Name,$user.GivenName,$user.Surname
			}
		}
	}
	# return the name of the selected group for use by other functions.
	return $group.Name
}


