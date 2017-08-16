function Get-GroupMembership
{
	<#
	.SYNOPSIS
	Passes a User id to find and select the groups the user is a member of.
	.DESCRIPTION
	Passes a User id to find and select the groups the user is a member of.
	Populates a grid view and allows selection of the groups using CTRL and Mouse click to copy the groups in preparation of adding them to another user.
	Ideal for new user group permission creation. 
	.EXAMPLE
	Get-GroupMembership -ADUserId <UserId>
	#>
	param
	(
		[Parameter(Mandatory, Position=0)]
		[String]
		$ADUserId
	)
	# Get the groups a user is a member of and populate the $GroupList variable
	$GroupList = Get-ADPrincipalGroupMembership $ADUserId | Select-Object -Property Name
	$Idx=0
	# Pipe the groups into a GridView
	$GroupsId = $(foreach ($item in $GroupList){
			$item | Select-Object -Property @{l='IDX'
			e={$Idx}}, Name
	$Idx++	}) |
	Out-GridView -Title 'Select the Groups to Copy to new user' -OutputMode Multiple |
	ForEach-Object { $GroupList[$_.IDX] }	 
	
	# return the selected groups to be used by another function.
	return $GroupsId
}

