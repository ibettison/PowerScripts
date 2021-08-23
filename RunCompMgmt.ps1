$session = New-PSSession -ComputerName FMS-CAV-L33 -Credential campus\nib8
Invoke-Command -Session $session -ScriptBlock {get-WmiObject win32_logicaldisk}