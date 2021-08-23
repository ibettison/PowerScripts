   param
   (
     [Parameter(Mandatory, Position=0)]
     [String]
     $DateStamp,
     [Parameter(Mandatory, Position=1)]
     [String]
     $remoteFiles,
     [Parameter(Mandatory, Position=2)]
     [String]
     $Computer
   )

   try{

     $WhoseloggedIn = Get-WmiObject -ComputerName $Computer -Class Win32_ComputerSystem | Select-Object UserName

     ("The Logged in users are: {0}" -F $WhoseloggedIn) | Add-Content -Path (('{1}{0}-ScriptEventLog.txt' -f $DateStamp, $remoteFiles))
   }
   catch{
      ("An error has occurred: {0}" -F $_) | Add-Content -Path (('{1}{0}-ScriptEventLog.txt' -f $DateStamp, $remoteFiles))  
   }