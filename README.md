Azure Log Alerts to IcM - Triggers IcM for Azure Log based alerts
=================================================================

            



 




The script receives the incoming log alert data from Azure Log Analytics and Application Insights. Using the configuration available in the automation account, it creates equivalent ICM incidents in appropriate ICM environment. The runbook is dependent on
 the AzureLogAlertsICMConnector module which needs to be downloaded separately. The severity of the ICM incident will be mapped to the severity of the Alert rule if not specified in runbook configuration.


 




 




        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
