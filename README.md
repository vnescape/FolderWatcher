# Folder Watcher
A PowerShell script that monitors a folder for changes (create, modify, delete) and also displays the changes.

## Usage

`.\folder_watcher.ps1 <folder-path>`

## Example
```
\folder_watcher.ps1 "C:\Users\user\AppData\LocalLow\NVIDIA\PerDriverVersion\DXCache"
FileSystemWatcher is monitoring C:\Users\user\AppData\LocalLow\NVIDIA\PerDriverVersion\DXCache
2024-10-25 19:00:17 - Changed: C:\Users\user\AppData\LocalLow\NVIDIA\PerDriverVersion\DXCache\428504a9d65d1f8ebc4a22780e61a6fb_fce8395c8fd8a93b_6b51858aa9bab9e0_0_0.0.toc
2024-10-25 19:00:53 - Created: C:\Users\user\AppData\LocalLow\NVIDIA\PerDriverVersion\DXCache\428504a9d65d1f8ebc4a22780e61a6fb_fce8395c8fd8a93b_6b51858aa9bab9e0_0_1.2.toc
Current folder size: 590.72 MB (Change: 1 MB, increased)
2024-10-25 19:01:13 - Created: C:\Users\user\AppData\LocalLow\NVIDIA\PerDriverVersion\DXCache\428504a9d65d1f8ebc4a22780e61a6fb_fce8395c8fd8a93b_6b51858aa9bab9e0_0_1.2.bin
Current folder size: 606.72 MB (Change: 16 MB, increased)
```