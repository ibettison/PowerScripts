$SearchAD = "CTU"
$DaysInactive = 365
$time = (Get-Date).Adddays(-($DaysInactive))
Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -ResultPageSize 2000 -resultSetSize $null -Properties Name, OperatingSystem `
-SearchScope Subtree -SearchBase "OU=$SearchAD,OU=Departments,DC=campus,DC=ncl,DC=ac,DC=uk" | Format-Table `
-Property Name, OperatingSystem, DistinguishedName