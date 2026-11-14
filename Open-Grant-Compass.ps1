$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
Write-Host 'Grant Compass files are saved in:' $PSScriptRoot
Write-Host 'Opening the project instructions and grant research.'
Start-Process notepad.exe -ArgumentList (Join-Path $PSScriptRoot 'README.md')
Start-Process notepad.exe -ArgumentList (Join-Path $PSScriptRoot 'GRANT_RESEARCH.md')
Write-Host 'The APK has not been built. Follow README.md after installing Flutter and the Android SDK.'
