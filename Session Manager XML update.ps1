#####################################################################################
#Script Created by Phillip Marshall                                                 #
#Creation Date 1/27/15                                                              #
#Revision 1                                                                         #
#Revisions Changes - N/A                                                            #
#                                                                                   #
#Revision 2                                                                         #
#Revisions Changes - Changes the XML document paths to variables for easier updating#
#in the future.                                                                     #
#                                                                                   #
#Description - This Script will Pull information from the Users.xml file and update #
#the SessionGroup.xml with the values pulled.                                       #
#                                                                                   #
#                                                                                   #
#####################################################################################

$Userspath = 'C:\Users\pmarshall\documents\User.xml'
$SessionPath = 'C:\Users\pmarshall\documents\SessionGroup.xml'

#Pulls the User.xml file into a variable
[XML]$Users = Get-Content $Userspath

#Gets the max row count from the document and establishes $i for the while loop.
$max = $Users.Users.user.count
$i = 0

#Creates the arrays to hold the data
$Serviceplus= @()
$StandardSupport= @()
$Consulting= @()
$Onboarding= @()

#Pulls all the needed user values and adds them to corresponding arrays.
While ($i -lt $max)
{
   If ( $users.users.user[$i].roles.InnerText -match 'ServicePlus'){$Serviceplus+= $users.users.user[$i].Name}
   If ( $users.users.user[$i].roles.InnerText -match 'Standard Support'){$StandardSupport+= $users.users.user[$i].Name}
   If ( $users.users.user[$i].roles.InnerText -match 'Consulting'){$Consulting+= $users.users.user[$i].Name}
   If ( $users.users.user[$i].roles.InnerText -match 'Onboarding'){$Onboarding+= $users.users.user[$i].Name}

   $i++
}

#Opens each Xpath from the SessionGroup.xml file and updates the values with the Strings from the corresponding array.

$XMLSelection = Select-Xml -Path $SessionPath -XPath '/SessionGroups/SessionGroup[16]/@SessionFilter'
$XMLSelection.node.'#text' = $StandardSupport -join ','
$XMLSelection.node.OwnerDocument.save($XMLSelection.path)

$XMLSelection = Select-Xml -Path $SessionPath -XPath '/SessionGroups/SessionGroup[17]/@SessionFilter'
$XMLSelection.node.'#text' = $Serviceplus -join ','
$XMLSelection.node.OwnerDocument.save($XMLSelection.path)

$XMLSelection = Select-Xml -Path $SessionPath -XPath '/SessionGroups/SessionGroup[18]/@SessionFilter'
$XMLSelection.node.'#text' = $Consulting -join ','
$XMLSelection.node.OwnerDocument.save($XMLSelection.path)

$XMLSelection = Select-Xml -Path $SessionPath -XPath '/SessionGroups/SessionGroup[19]/@SessionFilter'
$XMLSelection.node.'#text' = $Onboarding -join ','
$XMLSelection.node.OwnerDocument.save($XMLSelection.path) 
