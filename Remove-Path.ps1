Function Remove-OldFile
{
	
		<#
	.SYNOPSIS
		A function to test and remove paths.
	
	.DESCRIPTION
		Pass a path to the function. It will test the connection and
		remove the item if it exists.
	
	.PARAMETER $FilePath
		The filepath to test.
	
	.EXAMPLE
		PS C:\> Remove-OldFile -Filepath $Path
	
	.NOTES
		N/A
	#>
	
	param
	(
		[parameter(Mandatory = $true)]
		[string]$Path
	)
	
	If (Test-Path $Path)
	{
		Remove-Item $Path -Force
	}
	
}