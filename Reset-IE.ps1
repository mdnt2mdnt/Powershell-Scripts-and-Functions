Function Reset-IE 
{
[void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089") 
$ShellApp = New-Object -ComObject Shell.Application
$ShellApp.Windows() | Where { $_.Name -eq "Windows Internet Explorer" } | ForEach { $_.Quit() }
& rundll32.exe inetcpl.cpl,ClearMyTracksByProcess 4351 
}
