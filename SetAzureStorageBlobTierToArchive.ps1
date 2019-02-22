Import-Module AzureRM

#Define storage account information
$StorageAccount = "STORAGEACCOUNTNAME"
$StorageAccountKey = "STORAGEACCOUNTKEY"
$containername = "CONTAINERNAME"
 
#Create a storage context
$context = New-AzureStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $StorageAccountKey

#Set variables for processing batches & continuation Token

$MaxReturn = 50000
$Token = $Null

#Define a blog array for reporting
$blobarray = @()

#Create a loop to process the whole container in blob batches of 50,000

do
 {
     
     #Process a total of 50,000 Blobs at a time. This is extremely useful for large containers
     $blobs = Get-AzureStorageBlob -Container $containername -Context $context -MaxCount $MaxReturn -ContinuationToken $Token

     #I schedule this script to run every hour, so I've configured the below filter to only process specific blobs. NBLOBS is short for New Blobs!
     
     $nblobs = $blobs | where {$_.LastModified -gt (Get-Date).AddMinutes(-90)} | Where-Object {$_.ICloudBlob.Properties.StandardBlobTier -eq 'Cool'}

     # A 'For' loop to process the filtered out blobs

     foreach($nblob in $nblobs) {

        #Change the access tier of the newly uploaded blogs

        $nblob.ICloudBlob.SetStandardBlobTier("Archive")

        #Add these blobs to our array

        $blobarray += $nblob

                } 
     
     if($blobs.Length -le 0) { Break;}

     $Token = $blobs[$blobs.Count -1].ContinuationToken;
 }
 While ($Token -ne $Null)

#Export results of changed blogs to CSV file

$timestamp = Get-date -UFormat %d%m%y%H%M

$fulldate = Get-Date -Format g 

$export = "C:\temp\Blob Tier Updates - $containername $timestamp.csv"

$blobarray | Select-Object -Property Name, BlobType, LastModified, Length, ContentType, @{n='AccessTier';e={$_.ICloudBlob.Properties.StandardBlobTier}} | Export-Csv $export -NoTypeInformation

#Email CSV file to pre-determined recipients

#Start-Sleep -s 5

#$smtpServer ="8.8.8.8"
#$file = $export
#$att = new-object Net.Mail.Attachment($file)
#$msg = new-object Net.Mail.MailMessage
#$smtp = new-object Net.Mail.SmtpClient($smtpServer)
#$msg.From = "name@test.com"
#$msg.To.Add("name1@test.com")
#$msg.Subject = "$timestamp : Azure Blob Storage Updates"
#$msg.Body = "Report attached for Blob Tier Updates on $containername Storage container on $fulldate"
#$msg.Attachments.Add($att)
#$smtp.Send($msg)
#$att.Dispose()
