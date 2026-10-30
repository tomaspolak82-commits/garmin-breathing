# Builds bin\Koherence-<device>.prg using the portable JDK in .tools
# Usage: .\build.ps1 [-Device fr165m|venu441mm|venu445mm]
param([string]$Device = 'fr165m')
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$jdk = Get-ChildItem "$root\.tools" -Directory -Filter 'jdk-*' | Select-Object -First 1
$sdk = (Get-Content "$env:APPDATA\Garmin\ConnectIQ\current-sdk.cfg" -Raw).Trim()

$env:JAVA_HOME = $jdk.FullName
$env:PATH = "$($jdk.FullName)\bin;$sdk\bin;$env:PATH"

New-Item -ItemType Directory -Force "$root\bin" | Out-Null
& monkeyc -d $Device -f "$root\monkey.jungle" -o "$root\bin\Koherence-$Device.prg" -y "$root\.tools\developer_key.der" -w
if ($LASTEXITCODE -ne 0) { throw "Build failed" }
