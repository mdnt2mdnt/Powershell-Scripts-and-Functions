$b = (Get-ChildItem "\\desktop\c$\Users" -Recurse | measure-object -Property length -sum).sum; "{0:N0}" -f ($b / 1MB)
