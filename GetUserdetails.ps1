﻿Get-ADUser -Filter 'SurName -like "Liddle"' | Format-Table Name,SamAccountName,GivenName,Surname -A