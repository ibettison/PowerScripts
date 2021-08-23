$folders = Get-ChildItem -Path "S:\Trials\" -Recurse 

Foreach($folder in $folders){
  Remove-Item -Recurse -Path $folder.FullName
  }