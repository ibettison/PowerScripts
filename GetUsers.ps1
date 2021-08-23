$users = ForEach ($user in $(Get-Content C:\temp\users\users.txt)) {

  $username = $user.Split("\")  
  Get-AdUser $username[1] -Properties GivenName, Surname, Department ,Mail
        
}
    
 $users |
 Select-Object SamAccountName, GivenName, Surname, Department, Mail |
 Export-CSV -Path C:\temp\users\output.csv -NoTypeInformation