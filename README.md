# NC2AzureNetworkDeployment
Used to deploy an NC2 cluster in Azure. Two Networks for PC and AHV. NATs are deployed with public IPs. 
The ranges used in these files are for POCs. The default CIDR are larger when using the NC2 portal.
The only step that still has to be done manually is delegation to the Microsoft.BareMetal/AzureHostedService
