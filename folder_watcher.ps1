# Check if a command-line argument is provided
if ($args.Count -eq 0) {
    Write-Host "Usage: .\folder_watcher.ps1 <folder-path>"
    exit
}

# Get the path from the command line argument
$Path = $args[0]

# Check if the specified path exists
if (-Not (Test-Path $Path)) {
    Write-Error "The specified path does not exist. Please check the path and try again."
    exit
}

# Specify which files you want to monitor
$FileFilter = '*'  

# Specify whether you want to monitor subfolders as well:
$IncludeSubfolders = $true

# Specify the file or folder properties you want to monitor:
$AttributeFilter = [IO.NotifyFilters]::FileName, [IO.NotifyFilters]::LastWrite 

# Specify the type of changes you want to monitor:
$ChangeTypes = [System.IO.WatcherChangeTypes]::Created, [System.IO.WatcherChangeTypes]::Deleted, [System.IO.WatcherChangeTypes]::Changed

# Specify the maximum time (in milliseconds) you want to wait for changes:
$Timeout = 1000

# Specify the path for the log file
$LogFile = Join-Path -Path $Path -ChildPath 'FileChangeLog.txt'

# Define a function that gets the size of the folder
function Get-FolderSize {
    param (
        [string]$FolderPath
    )
    $size = (Get-ChildItem -Path $FolderPath -Recurse -Force | Measure-Object -Property Length -Sum).Sum
    return $size / 1MB  # Returns size in MB
}

# Define a function that gets called for every change:
function Invoke-SomeAction {
    param (
        [Parameter(Mandatory)]
        [System.IO.WaitForChangedResult]
        $ChangeInformation
    )

    # Log the change
    $changeType = $ChangeInformation.ChangeType
    $fileName = $ChangeInformation.Name
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

    # Construct the full file path
    $filePath = Join-Path -Path $Path -ChildPath $fileName

    # Create log entry
    $logEntry = "$timestamp - $($changeType): $filePath"
    
    # Output change detected
    Write-Host $logEntry -ForegroundColor DarkYellow

    # Append log entry to log file
    Add-Content -Path $LogFile -Value $logEntry

    # Get the current folder size
    $currentFolderSize = Get-FolderSize -FolderPath $Path

    # Only print the new folder size if it has changed
    if ($currentFolderSize -ne $script:previousFolderSize) {
        $sizeChange = $currentFolderSize - $script:previousFolderSize
        
        # Check if the change is less than 1 MB
        if ([math]::Abs($sizeChange) -lt 1 -and $sizeChange -ne 0) {
            # Round up to the next decimal place if less than 1 MB
            $roundedSizeChange = [math]::Ceiling($sizeChange * 10) / 10
        } else {
            # Round to one decimal place if 1 MB or more
            $roundedSizeChange = [math]::Round($sizeChange, 1)
        }

        $changeDirection = if ($sizeChange -gt 0) { "increased" } else { "decreased" }

        Write-Host "Current folder size: $currentFolderSize MB (Change: $roundedSizeChange MB, $changeDirection)" -ForegroundColor Cyan
        $script:previousFolderSize = $currentFolderSize  # Update the previous size
    }
}

# Initialize the previous folder size
$script:previousFolderSize = Get-FolderSize -FolderPath $Path

# Use a try...finally construct to release the
# FileSystemWatcher once the loop is aborted
# by pressing CTRL+C

try {
    Write-Host "FileSystemWatcher is monitoring $Path" -ForegroundColor Green
  
    # Create a FileSystemWatcher object
    $watcher = New-Object -TypeName IO.FileSystemWatcher -ArgumentList $Path, $FileFilter -Property @{
        IncludeSubdirectories = $IncludeSubfolders
        NotifyFilter = $AttributeFilter
    }

    # Start monitoring manually in a loop:
    do {
        # Wait for changes for the specified timeout
        $result = $watcher.WaitForChanged($ChangeTypes, $Timeout)
        
        # If there was a timeout, continue monitoring:
        if ($result.TimedOut) { continue }
        
        Invoke-SomeAction -ChangeInformation $result
        # The loop runs forever until you hit CTRL+C    
    } while ($true)
}
finally {
    # Release the watcher and free its memory:
    $watcher.Dispose()
    Write-Host 'FileSystemWatcher removed.' -ForegroundColor Red
}
