Get-OutlookAnywhere -ADPropertiesOnly | Select Server,InternalHostName,ExternalHostName
Get-OwaVirtualDirectory -ADPropertiesOnly | Select Server,InternalUrl,ExternalUrl
Get-ECPVirtualDirectory -ADPropertiesOnly | Select Server,InternalUrl,ExternalUrl
Get-OABVirtualDirectory -ADPropertiesOnly | Select Server,InternalUrl,ExternalUrl
Get-WebServicesVirtualDirectory -ADPropertiesOnly | Select Server,InternalUrl,ExternalUrl
Get-MAPIVirtualDirectory -ADPropertiesOnly | Select Server,InternalUrl,ExternalUrl
Get-ActiveSyncVirtualDirectory -ADPropertiesOnly | Select Server,InternalUrl,ExternalUrl
Get-ClientAccessServer | Select Identity,AutoDiscoverServiceInternalUri