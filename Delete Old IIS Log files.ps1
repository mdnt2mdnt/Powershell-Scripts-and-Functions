#####################################################################################
#Function Created by Phillip Marshall												#
#Creation Date 6/5/14																#
#Revision 2																			#
#Revisions Changes - Added Commenting.												#
#																					#
#Description - This script will delete IIS log files older than 'X' months.			#
#																					#
#####################################################################################

$logfiles = 'C:\WINDOWS\system32\LogFiles\W3SVC1\*.log'
$total_bytes = 0
dir $logfiles | ? { $_.lastWriteTime -lt (Get-Date).AddMonths(-3) } |  % { $total_bytes += $_.Length; $_ } |  del -force
Write-Host "Recovered $total_bytes bytes."function Zip-Files
{
	<#
	.SYNOPSIS
		Zips up selected files into a named zip file.
	
	.DESCRIPTION
		Allows you to pass a list of files or folders to the function and creates a named zip.
	
	.PARAMETER ZipName
		A description of the ZipName parameter.
	
	.PARAMETER ZipPath
		A description of the ZipPath parameter.
	
	.PARAMETER FolderPath
		A description of the FolderPath parameter.
	
	.EXAMPLE
				PS C:\> Zip-Files -ZipName 'Value1' -ZipPath 'Value2'
	
	.NOTES
		Additional information about the function.
#>
	
	[CmdletBinding(
				   PositionalBinding = $true,
				   SupportsPaging = $false,
				   SupportsShouldProcess = $false)]
	param
	(
		[Parameter(Mandatory = $true,Position = 0)][string]$ZipPath,
		[Parameter(Mandatory = $true,Position = 1)][string]$FolderPath
	)
	
	If (Test-path $ZipPath) { Remove-item $ZipPath }
	
	Add-Type -assembly "system.io.compression.filesystem"
	[io.compression.zipfile]::CreateFromDirectory($FolderPath, $ZipPath)
	
	If (Test-path $ZipPath) { Return "Success" }
	Else {Return "Failure" }
}
