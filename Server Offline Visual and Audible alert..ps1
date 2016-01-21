Function DangerWillRobinson
{
    Param(

        
        #.PARAMETER Servername = The name of the machine that is offline. This is passed from the LT script.
        
            [Parameter(Mandatory=$True,Position=0)]
            [String]$Servername,
                    
        #.PARAMETER ClientName = The name of the client that the offline server belongs to. This is passed from the LT script.
        
            [Parameter(Mandatory=$True,Position=1)]
            [String]$ClientName,

        #.PARAMETER URL = The web page to load.
            [Parameter(Mandatory=$True,Position=2)]
            [String]$URL
            )


    Function NavigateTo
    {

        Param(

        
        #.PARAMETER URL = The HTML page to open.
        
            [Parameter(Mandatory=$True,Position=0)]
            [String]$URL,
            
        
        #.PARAMETER DelayTime = The delay for opening the page.
        
            [Parameter(Mandatory=$False,Position=1)]
            [int]$Delaytime = 100
            )

        $global:ie.Navigate($url)

        WaitForPage $delayTime
}

    Function WaitForPage
    { 
        Param(
     
            [Parameter(Mandatory=$True,Position=0)]
            [int]$Delaytime = 100
     
            )
    
    

            $loaded = $false
            while ($loaded -eq $false) 
            {
                [System.Threading.Thread]::Sleep($delayTime) 
                #If the browser is not busy, the page is loaded
                if (-not $global:ie.Busy)
                {
                    $loaded = $true
                }
            }

        $global:doc = $global:ie.Document
        Say-text $Message
    }

    function Say-Text 
    {

        Param (
        <#
        .PARAMETER Message = The phrase to say.
        #>
                [Parameter(Mandatory=$True,Position=0)]
                [String]$Message

              )
    
            [Reflection.Assembly]::LoadWithPartialName('System.Speech') | Out-Null   
            $object = New-Object System.Speech.Synthesis.SpeechSynthesizer 
            $object.Speak($Message)
            $object.Speak($Message) 
            $object.Speak($Message)  
    }

$global:ie = New-Object -com "InternetExplorer.Application"
$global:ie.Navigate("about:blank")
$global:ie.visible = $true
$message = "WARNING.     WARNING.    WARNING.   Server $Servername for client $clientname is offline."
NavigateTo $url

}
DangerWillRobinson