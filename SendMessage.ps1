$computer = 'crf88'
$who = Get-WmiObject -ComputerName $computer -Class Win32_ComputerSystem | Select-Object UserName

$user = [String]$who.UserName.Split("CAMPUS\")
$name = Get-ADUser $user
$name = $name.GivenName
Invoke-Command -ComputerName $computer -ArgumentList $name -Scriptblock {param($name) $CmdMessage = {C:\windows\system32\msg.exe * "Please reboot your machine, $name"} 
$CmdMessage | Invoke-Expression }