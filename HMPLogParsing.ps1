[xml]$Hitman = get-content "%windir%\ltsvc\packages\hitmanpro\%computername%-clean.xml"
$childnodes = $hitman.DocumentElement.childnodes

    foreach($node in $childnodes)
    {
        If ([Float]$node.score -gt 1)
        {
            Try{
                    $Type = $node.type
                    $Malware = $node.malwarename
                    $Name = $node.scanners.scanner.Name
                    $Score = $node.score
                    $Path = $node.file.path
               }
            Catch{}


$Output = @"
 ----------------------------------------------
|Type - $Type
|Category - $Malware
|Malware Name - $Name
|Score = $Score
|Path = $Path
 ----------------------------------------------



"@

Write-Output $output          

        }
        
        
    }
