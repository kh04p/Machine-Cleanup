#When filtering, please make sure Source is set to "Tanium Scripts".
#Event IDS for this script will be:
#	4001: Machine Cleanup script was executed.

#Logs to Event Viewer under Application.
function logEvent {
	param([string]$msg,[string]$entry,[string]$id)
	Write-Host "Writing to Event Viewer..."
	$source = "Tanium Scripts"

	#Creates new source in Event Viewer named "Tanium Scripts" if needed
	If ([System.Diagnostics.EventLog]::SourceExists($source) -eq $False) {
		New-EventLog -LogName Application -Source $source
	}
	
	#Creates event with given information
	Write-EventLog -LogName "Application" -Source $source -EventID $id -EntryType $entry -Message $msg
    $msg | Out-File -FilePath C:\Temp\MachineCleanup_Output.txt
}

#Creates registry key to specify Disk Cleanup options
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\*' | % {
    New-ItemProperty -Path $_.PSPath -Name StateFlags0001 -Value 2 -PropertyType DWord -Force
}

#Starts disk cleanup
Write-Host "Starting Disk Cleanup..."
Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:1' -WindowStyle Hidden

#Starts SFC Scan
Write-Host "starting SFC scan..."
Start-Process -FilePath "C:\Windows\System32\sfc.exe" -ArgumentList '/scannow' -RedirectStandardOutput C:\temp\SFC_Results.txt -Wait -NoNewWindow

#Logs to Event Viewer
logEvent -msg "Machine Cleanup script was executed on computer $env:COMPUTERNAME. Logs for SFC scan can be found in C:\temp." -entry Information -id "4001"