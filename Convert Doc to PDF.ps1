Function Convert-WordToPDF 
{
	<#
.SYNOPSIS
 Converts Word documents to PDF files.

 For examples, type:
 Help Convert-WordToPDF -examples
.DESCRIPTION
 This function uses the Word.Application COM Object to convert .doc or
 .docx files to PDF files. By default this function works on .doc files,
 If the file to be converted is a .docx file, use the -docx switch.
.PARAMETER Path
 The full path (including file name) to the document to be converted.
.PARAMETER Docx
 This optional switch allows the conversion of .docx files to PDF. If 
 this switch is omitted, and a .docx file is specified, the Function 
 will still convert the file, however the resulting file will have an 
 extension of .pdfx (you just need to delete the "x" off the end, and
 the file will open fine).
.EXAMPLE
 C:\PS>Convert-WordToPDF c:\test.doc

 This example will convert the file c:\test.doc to a PDF file. The 
 resulting file will be saved to c:\test.pdf (the .doc file will not be 
 deleted).

.EXAMPLE
 C:\PS>Convert-WordToPDF c:\test.docx -docx

 This example will convert the file c:\test.docx to a PDF file. The 
 resulting file will be saved to c:\test.pdf (the .docx file will not be
 deleted).

.EXAMPLE
 C:\PS>"c:\test.doc" | Convert-WordToPDF

 This example will do the same thing as EXAMPLE 1, showing how to pass
 a document to the function for conversion using pipelining.


#>
	[CmdletBinding()]
	Param
	(
	    [Parameter(ValueFromPipeline=$True,Position=0,Mandatory=$True)] 
	    [String]$Path
	)
	
	
	$Word = New-Object -Com Word.Application
	$Word.Visible = $False
	
	If (!(test-path $Path)){write-host "File $Document does not exist!";Break;}
	
	$existingDoc=$word.Documents.Open($Path)
	
	If($Docx){$SaveAsPath = $Path.Replace('.docx','.pdf')}
	Else {$SaveAsPath = $Path.Replace('.doc','.pdf')}
	
	If(test-path $SaveAsPath){rm $SaveAsPath}
	
	$ExistingDoc.SaveAs( [ref] $SaveAsPath, [ref] 17 )
	$existingDoc.Close()
	$Word.Quit()
}