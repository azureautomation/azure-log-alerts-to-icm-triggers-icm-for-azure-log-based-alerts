<#
.SYNOPSIS
	Azure Log Alerts ICM Connector runbook script facilitates creation of IcM incidents from Azure Log alerts.
.DESCRIPTION
	The script receives the incoming log alert data from Azure Log Analytics and Application Insights. 
    Using the configuration available in the automation account, it creates equivalent ICM incidents in appropriate ICM environment. 
    It requires the AzureLogAlertsICMConnector module.
.EXAMPLE
	Create-AzureLogAlertToIcM.ps1 -Webhookdata =$object. 
.NOTES
    AUTHOR: Adarsh Mohata
    LASTEDIT: Feb 21, 2018
#>
param(
		[object] $WebhookData
	)
if ($WebhookData -ne $null) {
	# Getting the configuration from the automation variables

    # Required variables
	$connectorId = Get-AutomationVariable -Name "connectorID"
	$certThumbprint = Get-AutomationVariable -Name "certThumbprint"
	$certPassword = Get-AutomationVariable -Name "certPassword"
	$environment = Get-AutomationVariable -Name "environment"
    $severity = Get-AutomationVariable -Name "severity"	
    $correlationID = Get-AutomationVariable -Name "correlationID"
	$routingID = Get-AutomationVariable -Name "routingID"
    
    if (!$severity)
    {
        # The severity of ICM Incident will be mapped to the severity of the Alert rule.
        $severity = -1
    }
					
	# Exporting the certificate to local drive of the machine where runbook script is executed
	$cert = Get-AutomationCertificate -Name 'azure-alerts-icm-connector'
	$pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2($cert)
	$pfxContentType = [System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx
	[byte[]]$pfxBytes = $pfx.Export($pfxContentType,$certPassword)
	[io.file]::WriteAllBytes('C:\Temp\azure-alerts-icm-connector.pfx',$pfxBytes)
	Write-Output "Exporting Certificate $certThumbprint complete"
	
	# Importing the certificate to 'My' certificate store under current user
	$certPath = "C:\Temp\azure-alerts-icm-connector.pfx"
	$certRootStore = "CurrentUser"
	$certStore = "My"
	$pfxPass = $certPassword
	$pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2
	$pfx.import($certPath, $pfxPass, "Exportable,PersistKeySet")
	$store = new-object System.Security.Cryptography.X509Certificates.X509Store($certStore, $certRootStore)
	$store.Open("MaxAllowed")
	$store.add($pfx)
	$store.close()

	# Parsing the input data starts here
	Write-Output "WebHook Data received from Azure Alert : $WebhookData"
	Import-Module AzureLogAlertsICMConnector.dll
	
	# Calling the createICMIncident method on the custom module
	$webHookBody = $WebhookData.RequestBody
	$webHookBody = $webHookBody | Out-String
	Write-Output "Body: $webHookBody"	
    Write-Output "Azure alert send to IcM"	
  	$createdIcMIncidentID = [AzureLogAlertsICMConnector.ICMConnector]::createICMIncident($connectorId,$certThumbprint,$webHookBody,$correlationID,$routingID,$environment,$severity)	
    Write-Output "IcM Incident Id : $createdIcMIncidentID"
}
else
{
    Write-Error "Webhook data for Azure alert can't be null"
}
