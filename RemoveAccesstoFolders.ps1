
  try {
    $path = '\\campus\dept\ihs\programmes\ctu\TRIALS\rads2'
    Set-Owner -path $path -Account 'campus\sib8'
    $acl = get-acl -Path $path
    Get-Credential
    $rule = [string]::Empty
    # Only look for explicit Allow ACEs
    foreach ($usr in ($acl.access | Where-Object { $_.IdentityReference -eq 'campus\srw40' -and $_.IsInherited -eq $false -and $_.AccessControlType -eq 'Allow' })) {
      $rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList (
        $usr.IdentityReference,
        'Read',
        $usr.InheritanceFlags,
        $usr.PropagationFlags,
        $usr.AccessControlType
      )
      $acl.RemoveAccessRuleAll($rule)
    }
    if(-not [string]::IsNullOrEmpty($rule))
    {
      'Please wait the removal is working...'
      Set-Acl -Path $path -AclObject $acl
      'The removal of Access has finished...'
    }
    else 
    {
      "The path $path was not changed"
    }
    
  } catch 
  { 
    Write-Verbose -Message "`nAn error has occurred. `n`nERROR - " 
  }