function Zip-Actions
{
	<#
	.SYNOPSIS
		A function to zip or unzip files.
	
	.DESCRIPTION
		This function has 3 possible uses.
		1) Zip a folder or files and save the zip to specified location.
		2) Unzip a zip file to a specified folder.
		3) Unzip a zip file and delete the original zip when complete.	
	
	.PARAMETER ZipPath
		The full path of the file to unzip or the full path of the zip file to be created.
	
	.PARAMETER FolderPath
		The path to the files to zip or the path to the directory to unzip the files to.
	
	.PARAMETER Unzip
		If $true the function will perform an unzip instead of a zip
	
	.PARAMETER DeleteZip
		If set to $True the zip file will be removed at then end of the unzip operation.
	
	.EXAMPLE
		PS C:\> Zip-Actions -ZipPath 'C:\Windows\Temp\ziptest.zip' -FolderPath 
		PS C:\> Zip-Actions -ZipPath 'C:\Windows\Temp\ziptest.zip' -FolderPath 'C:\Windows\Temp\ZipTest' -Unzip $true
		PS C:\> Zip-Actions -ZipPath 'C:\Windows\Temp\ziptest.zip' -FolderPath 'C:\Windows\Temp\ZipTest' -Unzip $true -DeleteZip $True

	
	.NOTES
		Additional information about the function.
#>
	
	[CmdletBinding(DefaultParameterSetName = 'Zip')]
	param
	(
		[Parameter(ParameterSetName = 'Unzip')]
		[Parameter(ParameterSetName = 'Zip',
				   Mandatory = $true,
				   Position = 0)]
		[ValidateNotNull()]
		[string]$ZipPath,
		[Parameter(ParameterSetName = 'Unzip')]
		[Parameter(ParameterSetName = 'Zip',
				   Mandatory = $true,
				   Position = 1)]
		[ValidateNotNull()]
		[string]$FolderPath,
		[Parameter(ParameterSetName = 'Unzip',
				   Mandatory = $false,
				   Position = 2)]
		[ValidateNotNull()]
		[bool]$Unzip,
		[Parameter(ParameterSetName = 'Unzip',
				   Mandatory = $false,
				   Position = 3)]
		[ValidateNotNull()]
		[bool]$DeleteZip
	)
	
	switch ($PsCmdlet.ParameterSetName)
	{
		'Zip' {
			
			If (Test-path $ZipPath) { Remove-item $ZipPath }
			
			Add-Type -assembly "system.io.compression.filesystem"
			$Compression = [System.IO.Compression.CompressionLevel]::Optimal
			[io.compression.zipfile]::CreateFromDirectory($FolderPath, $ZipPath, $Compression, $True)
			break
			
		}
		
		'Unzip' {
			Add-Type -assembly "system.io.compression.filesystem"
			$Compression = [System.IO.Compression.CompressionLevel]::Optimal
			[io.compression.zipfile]::ExtractToDirectory($ZipPath, $FolderPath)
			
			If ($DeleteZip) { Remove-item $ZipPath }
			break
		}
	}
	
}