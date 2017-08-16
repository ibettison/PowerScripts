$ADGroup = 'CRF'

try 
{
	if([string]::IsNullOrEmpty($ADGroup))
	{
		throw 'Cannot search on NULL data.'
	}
	$ADGroup = '*' + $ADGroup + '*'
	Start-Job -Name getList -ScriptBlock {param([Parameter(Mandatory=$true,HelpMessage='Enter the Partial Group')][String]$pGroup) Get-ADGroup -Filter {Name -like $pGroup} -Properties * | Select-Object -Property Name, Description} -ArgumentList $ADGroup
	Wait-Job -Name getList
	$groupList = Receive-Job -Name getList
	if([string]::IsNullOrEmpty($groupList)) 
	{
		throw 'Group was not found.'
	}
	else
	{
		$Idx =0
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
if(-not [string]::IsNullOrEmpty($group)) 
{
    try
    {
        $members = Get-ADGroupMember -identity $group.Name -Recursive
    }
    catch 
    {        
        Write-Host -Message ("`nThe group name may have contained a typo as I did not find it. `n`nERROR - {0}" -f $_)
        Exit
    }

	if(-not [string]::IsNullOrEmpty($members))
	{
		$listUsers= @{}
		$arrayCount=0
		Write-Host "`nDisplaying the members of this group: "                
		foreach( $member in $members )
		{
			$listUsers[$arrayCount++] = Get-ADUser -Identity $member.SamAccountName | Select-Object -Property name, GivenName, Surname
		}		
		$listUsers.Values | Format-Table -autosize