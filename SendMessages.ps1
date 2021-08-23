$PCLIST = 'CRF88'
ForEach ($computer in $PCLIST) {

    Invoke-Command -ComputerName $computer -Scriptblock {
        $CmdMessage = {C:\windows\system32\msg.exe * 'Morning: How is your leg'}

        $CmdMessage | Invoke-Expression
    }

}