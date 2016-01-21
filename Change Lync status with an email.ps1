#VARIABLES AND STUFF!
#Enter the from address to verify against
$fromAddress = ""
#Enter your work address - to be used for sending reply notifications and for EWS auto discover
$yourAddress = ""
#Enter the address you want the reply notification/confirmation to be sent to (probably the same as the from address)
$replyAddress = ""
#Mail server for sending the reply notficiation/confirmation e-mail
$smtpServer = "outlook.office365.com"
 
#Function to set the status
Function SetLyncStatus {
    #Set up input parameters
    Param(
        [string]$statusText,
        [string]$lyncStatus
        )
    #Set up the Lync client object
    $lyncClient = [Microsoft.Lync.Model.LyncClient]::GetClient()
    #Switch statement for different status possibilities, capture result in $statusCode
    [int]$statusCode = Switch ($statusText) {
        Available {"3500"}
        Away {"15500"}
        BRB {"12000"}
        Busy {"6500"}
        DND {"9500"}
        }
    #Set up object to hold the status update information
    $contactInfo = New-Object 'System.Collections.Generic.Dictionary[Microsoft.Lync.Model.PublishableContactInformationType, object]'
    #New Availablity setting
    $contactInfo.Add([Microsoft.Lync.Model.PublishableContactInformationType]::Availability, $statusCode)
    #New Status setting
    $contactInfo.Add([Microsoft.Lync.Model.PublishableContactInformationType]::PersonalNote, $lyncStatus)
    #Setup the method to publish the information
    $updateMethod = $lyncClient.Self.BeginPublishContactInformation($contactInfo, $null, $null)
    #Publish it!
    $lyncClient.Self.EndPublishContactInformation($updateMethod)
    }
 
#Function to retrieve the current status
Function GetLyncStatus {
    #Set up the Lync client object
    $lyncClient = [Microsoft.Lync.Model.LyncClient]::GetClient()
    #Object containing this user's contact information
    $ownContact = $lyncClient.ContactManager.GetContactByUri($lyncClient.Uri)
    #Retrieve the availability code, and cast to that type so that we don't have to transform the integer back to plain text
    $setAvailability = [Microsoft.Lync.Model.ContactAvailability]$ownContact.GetContactInformation("Availability")
    #Do the same but this time retrieve the status
    $setStatus = $ownContact.GetContactInformation("PersonalNote")
    #Send the confirmation e-mail
    Send-MailMessage -To $replyAddress -From $yourAddress -SmtpServer $smtpServer -Subject "Your Lync status is $setAvailability" -Body "Your Lync status is $setAvailability with a note of $setStatus"
    }
 
#Load the assemblies and modules needed
Import-Module "C:\Program Files\Microsoft Office\Office15\LyncSDK\Assemblies\Desktop\Microsoft.Lync.Controls.Dll"
Import-Module "C:\Program Files\Microsoft Office\Office15\LyncSDK\Assemblies\Desktop\Microsoft.Lync.Model.Dll"
[Reflection.Assembly]::LoadFile("C:\Program Files\Microsoft\Exchange\Web Services\1.2\Microsoft.Exchange.WebServices.dll")
#Create the EWS object for connectivity
$EWSObj = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService([Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2010)
#Populate e-mail address for auto discover to work
$EWSObj.AutodiscoverUrl($yourAddress)
#Create an object to bind to the inbox
$inbox = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($EWSObj,[Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Inbox)
 
#Start the loop for the actual doing
Do {
    #Get messages, returning most recent 500 messages that are unread. Seems excessive, but fast enough.
    $updateMessages = $inbox.FindItems(500) | Where-Object {$_.IsRead -eq $False}
    #Load the full content for the previously gathered messages
    $updateMessages | ForEach {$_.Load()}
    #Now let's filter down even further by checking the sender address
    $updateMessages | ForEach {
        If ($_.From.Address -eq $fromAddress) {
            #If sender address is good, mark the message as read
            $_.IsRead = $true
            $_.Update("NeverOverwrite")
            #If statement to check for GetStatus message subject
            If ($_.Subject -eq "GetStatus") {
                GetLyncStatus
                }
            #If statement to check for SetStatus message subject
            If ($_.Subject -like "SetStatus*") {
                #Grab the new status and availability from the subject
                $splitSubject = $_.Subject.Split("/")
                $newLyncAvailability = $splitSubject[1]
                $newLyncStatus = $splitSubject[2]
                #Set the status
                SetLyncStatus -statusText $newLyncAvailability -lyncStatus $newLyncStatus
                #Wait just a few seconds for the status to fully update
                Start-Sleep -Seconds 7
                #Run GetLyncStatus to send an e-mail back to confirm
                GetLyncStatus
                }
            }
        }
    #Start a sleep of 60 seconds, and let it kick off again
    Start-Sleep -Seconds 60
    } Until ($i -gt 0)