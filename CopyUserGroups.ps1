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
Write-Host 'Please Wait! Searching for matching users...'
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
				Write-Verbose -Message ("`nERROR: {0}" -f $_)
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
# SIG # Begin signature block
# MIID3gYJKoZIhvcNAQcCoIIDzzCCA8sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1wTNKvXdULFu+ZGCp99hatP8
# EC6gggH9MIIB+TCCAWKgAwIBAgIQGSRf+W35IotAImM/6TUuxzANBgkqhkiG9w0B
# AQUFADAXMRUwEwYDVQQDDAxJYW4gQmV0dGlzb24wHhcNMTcwNDI4MDgzMDM3WhcN
# MjEwNDI4MDAwMDAwWjAXMRUwEwYDVQQDDAxJYW4gQmV0dGlzb24wgZ8wDQYJKoZI
# hvcNAQEBBQADgY0AMIGJAoGBAKuEcX8bvzsWz94mWGsHr1CHHvqg9YyWv4/wRAki
# KDvuMsOQJHPaiRRcKnwZN8NsA6ZST3LKH3hEycMBTK7N6aHPvz0gj1oOJkEE6UYv
# iO+nGYOPBgsmr/Jca0lUQJ5WUZywgYygrQJC48YgXwmWevqruKUmEpBR+O1i+DbP
# l8ERAgMBAAGjRjBEMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBQ3UR9H
# xueybrz56h+0tmfMxWHgYDAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQEFBQAD
# gYEAWLHmiaG9mMtr2z4e8q+ftK2yMh+5rR7n77rF/KPbWHV37FmB5S5o4IjdsTnE
# BPv1wUFFDyfac+rudVt4Cy5uyPVcO3FWQ34tuQgrZMid6v9OcAFAUWX1UvHOlI5M
# nVu10Y5SIsCtKThTWW5UWm0yCuIe+FsmnlvMWwFdANen3NoxggFLMIIBRwIBATAr
# MBcxFTATBgNVBAMMDElhbiBCZXR0aXNvbgIQGSRf+W35IotAImM/6TUuxzAJBgUr
# DgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMx
# DAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkq
# hkiG9w0BCQQxFgQUPmgCd+l82ugNxY1gVRHSjssspVgwDQYJKoZIhvcNAQEBBQAE
# gYB7Z2vT1cmBsW6O5dM0OFq0dNX+cDjm0SML13Wk8Cjqn200TNhCcjU8egCDRpmi
# RFaxCGxvIIc2Qw3sEPl9hB4SiCicfwNhswtVZcP6bnpTEtjr1zeGcR9hD1gzO/g7
# lk1zM5KzBqlpbfDFvs44xMzFQzMNtpbgPRWMXafrKgvdWg==
# SIG # End signature block
