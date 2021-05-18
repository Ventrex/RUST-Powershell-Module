<#
Rust powershell module 
Made by: Ventrex
Discord: https://discord.io/Vellias

#>


Function Update-Plugins {
<#
Check all plugins in gamefolder for last write time, then compare them with online creation time of the same plugin.
If online is newer. Download, if not do nothing.
Best usage at startup of server to check for new plugin updates. 

Example: Update-Plugins -Gamefolder "C:\GameServer\RUST" 
#>

param (
[string]$Gamefolder
)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$PluginFolder = "$Gamefolder\Oxide\Plugins"
$Plugins = Get-ChildItem $PluginFolder -Filter *.cs

Foreach ($Plugin in $Plugins){
$Basename = $Plugin.basename
$Local_Creation = (Get-ChildItem -Path $Plugin.FullName).lastwritetime | Get-Date -Format "dd-MM-yyyy HH:mm" 
$Plugin_Info = (Invoke-WebRequest https://umod.org/plugins/$Basename/versions.json -UseBasicParsing | ConvertFrom-Json).data | Where-Object {$_.is_latest -eq "True"}
$Plugin_Created = $Plugin_Info.created_at | Get-Date -Format "dd-MM-yyyy HH:mm" 

if ((((get-date $Local_Creation) - (Get-date $Plugin_Created))).TotalMinutes -lt "0"){
# if ($Verschil -lt "0"){
    $Download = $Plugin_Info.download_url
    Invoke-WebRequest -Uri $Download -UseBasicParsing -OutFile "$PluginFolder\$basename.cs" 
}
start-sleep -Seconds 3
}
}

Function Restart-Rust {
param (
$timeout = "60" 
)
$wshell = New-Object -ComObject wscript.shell;
$wshell.AppActivate('Rust Server')
Start-Sleep -Seconds 1
$wshell.SendKeys("restart $timeout")
Start-Sleep -Seconds 1
$wshell.SendKeys('{ENTER}')

}
