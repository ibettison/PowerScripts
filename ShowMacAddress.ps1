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
    $colItems = get-wmiobject -class "Win32_NetworkAdapterConfiguration" |Where-Object{$_.IpEnabled -Match "True"}  
     
    foreach ($objItem in $colItems) {  
     
        $machineinformation = $objItem | Select-Object Description,MACAddress 
        ("The MAC Address for this PC is: {0}" -F $machineinformation.MACAddress) | Add-Content -Path (('{1}{0}-ScriptEventLog.txt' -f $DateStamp, $remoteFiles))
    } 
    