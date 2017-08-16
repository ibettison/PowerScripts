Clear-Host
$GetOUs = Get-ADOrganizationalUnit -Filter 'Name -like "CRF*"'
$Idx =0
	$OUSelected = $(foreach ($item in $GetOUs){
			$item | Select-Object -Property @{l='IDX'
			e={$Idx}}, Name, DistinguishedName
	$Idx++	}) |
	Out-GridView -Title 'Select the OU to use' -OutputMode Single |
	ForEach-Object { $GetOUs[$_.IDX] }
	$OUSelected.DistinguishedName