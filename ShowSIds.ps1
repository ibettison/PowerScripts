$UserName = "s*"
$userFind = Get-ADUser -Filter {SamAccountName -like $userName} -Properties * | Select-Object SamAccountName, GivenName, Surname, Description
$userFind