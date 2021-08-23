function Get-GroupMemberList
{
  <#
      .SYNOPSIS
      Displays the users with access to selected folders
      .DESCRIPTION
      Allows the user to select a folder and gets the groups with access to the folders inside the selected folder. The user can then select on a returned list and selct the folders they
      want to know who has access to them. The access can be saved to a .txt file called memberlist.txt
      .EXAMPLE
      Get-GroupMemberList -folder \\campus\dept\CRF\IT -saveOuput $True 
      .RETURNS
      The members of the groups that have access to the manually selected folders and groups
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$false, Position=0)]
    [System.String]
    $folder,
    [Parameter(Mandatory=$false, Position=0)]
    [System.Boolean]
    $saveOutput
  )
  if([string]::IsNullOrEmpty($folder)) 
  {
    $folder = Get-Folder
  }
  $Results = @()
  
  $Groups = Get-FolderAccess -Path $folder
  if($saveOutput) {
    $Groups | Tee-object MemberList.txt
  }else{
    $Groups
  }
  
  ForEach ($group in $Groups) {
    $acl = $group.'Group/User'.Value
    $Name = $acl.Split("\")[1]
    If ((Get-ADObject -Filter "SamAccountName -eq '$Name'").ObjectClass -eq "group")
    {   ForEach ($User in (Get-ADGroupMember $Name -Recursive | Select-Object -ExpandProperty Name))
       { 
        try{
       
          $FullName = Get-ADUser $User
          $Results += New-Object PSObject -Property @{
            Group = $Name
            User = $User
            FullName = $FullName.Givenname + " " + $FullName.Surname
          } 
        }
        catch
        {
          Write-Host ('ERROR : {0}' -f $_)
          $FullName = ""
          $Results += New-Object PSObject -Property @{
            Group = $Name
            User = $User
            FullName = $FullName.Givenname + " " + $FullName.Surname
          } 
        }             
      }
    }
  }
  
  if($saveOutput) {
    $Results | Select-object * | Format-Table | Tee-Object MemberList.txt -Append
  }else{
    $Results | Select-Object * | Format-Table
  }  
}


# SIG # Begin signature block
# MIID3gYJKoZIhvcNAQcCoIIDzzCCA8sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWUaFB/+ko1YzS5lyXaAznQOF
# +XegggH9MIIB+TCCAWKgAwIBAgIQGSRf+W35IotAImM/6TUuxzANBgkqhkiG9w0B
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
# hkiG9w0BCQQxFgQUMHafAsrouBFGklM4w2bk0kfzDj4wDQYJKoZIhvcNAQEBBQAE
# gYBlvwweJVbTKNhJAw5K/tDJ6lM74oZ35Te96DniDPkG6KycTLdOqqOMG02Cqm+S
# ENjO0FN4k5tsnlNibHJ5OjTOhKd480wg4h8/rif9bN1rmYgqRJKMTVnFVrY+opVp
# 7Tq8OJrpt/7yX3N156g6Un4OlZ0nyrYJPO+/dDrkva8L1w==
# SIG # End signature block
