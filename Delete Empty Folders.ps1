Function Delete-EmptyFolders{

Param (
        <#
        .PARAMETER NewName = The top level directory of which all child items will be searched. Example : E:\ or C:\Windows\
        #>
                [Parameter(Mandatory=$True,Position=0)]
                [String]$RootPath
      )

Get-ChildItem $RootPath -recurse | Where {$_.PSIsContainer -and `
@(Get-ChildItem -Lit $_.Fullname -r | Where {!$_.PSIsContainer}).Length -eq 0} |
Remove-Item -recurse -whatif}
]