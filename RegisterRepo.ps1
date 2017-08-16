$path = '\\campus\dept\crf\IT\PowershellModuleRepo\ADModules'
Import-Module PowerShellGet

$repo = @{
  Name = "ADModules"
  sourceLocation = $path
  publishLocation = $path
  InstallationPolicy = 'Trusted'
}

Register-PSRepository @repo
