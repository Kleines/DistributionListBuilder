# DL_Builder_Final.ps1
# PURPOSE
#   This is designed as a common framework building M365 distribution lists
# Author: Stephen Kleine [kleines2015@gmail.com]
# Version 00.10 20210312
# Revision  
#	MVP
# KNOWN BUGS
#   

# Import all the needed modules
Import-Module ExchangeOnlineManagement -ea stop -wa stop
Import-Module ActiveDirectory -ea stop -wa stop

# Preparations
try {
	Connect-ExchangeOnline -Credential (get-aduser -Identity $env:USERNAME).UserPrincipalName  -ea stop -wa stop -ShowBanner:$false #Connect with current user's UPN
}
catch {
	write-Host "Either your user account doesn't have privileges or your password was entered incorrectly."
	Start-Sleep 10
	exit(1326) #net helpmsg return code
}
#DL build loop
$null = $BuildDl
Do {
	$null = $Throwaway
	$ProposedDistributionListName =  Read-Host "What is the DL name?"
	$Throwaway = Get-EXORecipient -Identity $ProposedDistributionListName -ea SilentlyContinue
	if ($Throwaway)	{write-host " DL Name $ProposedDistributionListName already exists " -foregroundcolor white -BackgroundColor red
		Continue
	} 
	$DistributionListSMTPAddress = $ProposedDistributionListName.replace(' ','')+'@'+$Env:USERDNSDOMAIN
	$Throwaway = Get-EXORecipient -Identity $DistributionListSMTPAddress -ea SilentlyContinue
	if ($Throwaway)	{write-host " DL email address $DisributionListSMTPAddress already exists " -foregroundcolor white -BackgroundColor red
		Continue #back to the top of the DL builder with you
	}
	$BuildDL = $True
}
Until ($BuildDL)

#Now to Manager for the list
Clear-Host #for debug only
$ListManager = $false
do {
	$ManagedBy = Read-Host "What's the UPN of the manager (leave blank for you)?"
	if ($ManagedBy -eq "") {
		$ManagedBy = (get-aduser -Identity $env:USERNAME).UserPrincipalName #No need to check this for validity, it would have bailed on connection if it was
		$ListManager = $True
	}
	try {
		$null = [mailaddress]$ManagedBy
		$ListManager = $True
	}
	catch {
		Write-host " $ManagedBy is not a valid email address. "
		$ListManager = $False
		Continue
	}
	try {
		Get-EXORecipient -Identity $ManagedBy -ErrorAction stop | out-null
		$ListManager = $True
	}
	catch {
		Write-host " $ManagedBy is not a $Env:USERDNSDOMAIN mail user. "
		$ListManager = $False
	}
}
Until ($ListManager)

#Finally, let's build this puppy

New-DistributionGroup -Name $ProposedDistributionListName -Type Distribution -PrimarySmtpAddress $DistributionListSMTPAddress -ManagedBy $ManagedBy -ErrorAction SilentlyContinue -ErrorVariable $Error

If ($Error) {Write-host "Error was $Error"}
Else {Write-host "$ProposedDistributionListName with email address $DistributionListSMTPAddress managed by $ManagedBy created without incident."}

exit(0)

