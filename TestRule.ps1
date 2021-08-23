            $acl = Get-Acl "\\campus\dept\CRF\IT\Projects"

            $ruleIdentity = Get-ADGroup -Filter 'name -like "*CTU_TEAM_SENIOR_TRIAL_*"' | %{$_.samaccountname}
            
            $ruleParams = $ruleIdentity, @("ReadAndExecute,Synchronize"), "ContainerInherit,ObjectInherit", "None", "Allow"
            $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($ruleParams)
            $acl.AddAccessRule($rule)
            (Get-Item "\\campus\dept\CRF\IT\Projects").SetAccessControl($acl)