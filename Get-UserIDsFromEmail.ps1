$file = 'C:\PowerScripts\user.txt'
$FileCSV = 'C:\PowerScripts\UserID.csv'
$emails = get-content $file
foreach ($item in $emails)
{
	$user = Get-ADUser -Filter {mail -eq $item} -Properties * | Select-Object SamAccountName,mail 
	
	$user.SamAccountName+","+$user.mail | Add-Content $FileCSV
}
