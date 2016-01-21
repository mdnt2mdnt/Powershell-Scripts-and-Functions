Param (
        <#
        .PARAMETER NewName = The final name of the computer after the rename process.
        #>
                [Parameter(Mandatory=$True,Position=0)]
                [String]$NewName,

        <# 
        .PARAMETER CurrentName = The current name of the machine to be renamed.
        #>
                [Parameter(Mandatory=$True,Position=1)]
                [String]$CurrentName,
              
        <# 
        .PARAMETER Username = The Username to be used for credentials.
        #>
                [Parameter(Mandatory=$True,Position=2)]
                [String]$Username,
        
        <# 
        .PARAMETER Password = The password to be used for credentials.
        #>
                [Parameter(Mandatory=$True,Position=3)]
                [String]$Password,

        <#
        .PARAMETER Reboot = Whether or not the machine is going to be automatically rebooted to make the change effective.
        #>

                [Parameter(Mandatory=$True,Position=4)]
                [String]$Reboot

      )
    
        
        $Version = $PSVersionTable.PSVersion.major
        $secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
        $mycreds = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)
                
        If ($Reboot -eq 'YES')
        {
            If ($version -ge 3) {Rename-Computer -NewName $NewName -Restart -PSCredential $MyCreds}
            Else {Get-WmiObject Win32_ComputerSystem -ComputerName $Currentname -Authentication 6 | ForEach-Object {$_.Rename($Newname,$Password,$Username)}Restart-Computer}
        }
        
        Else
        {
            If ($version -ge 3) {Rename-Computer -NewName $NewName -PSCredential $MyCreds}
            Else {Get-WmiObject Win32_ComputerSystem -ComputerName $Currentname -Authentication 6 | ForEach-Object {$_.Rename($Newname,$Password,$Username)}}
        }




                                  

 
 