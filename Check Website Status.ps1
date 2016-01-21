$HTTP_Request = [System.Net.WebRequest]::Create('http://www.cnn.com')
$HTTP_Response = $HTTP_Request.GetResponse()
$HTTP_Status = [int]$HTTP_Response.StatusCode

If ($HTTP_Status -eq 200) {$Result =  'SITE UP'}
Else {$Result = 'SITE DOWN'}

$HTTP_Response.Close()