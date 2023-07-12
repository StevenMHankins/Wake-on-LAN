﻿# ---------------------------------------------------------------------- 
#
# Purpose:  Enables Wake on LAN (WOL) settings on active wired network cards
#
# Usage : powershell.exe -f .\EnableWOL.ps1
#
# ---------------------------------------------------------------------- 
 
# Get all physical ethernet adaptors, not descriptors were added for my environment. You may not need them. 
$nics = Get-WmiObject Win32_NetworkAdapter -filter "AdapterTypeID = '0' `
                                                    AND PhysicalAdapter = 'true' `
                                                    AND NOT Description LIKE '%Centrino%' `
                                                    AND NOT Description LIKE '%wireless%' `
                                                    AND NOT Description LIKE '%WiFi%' `
													AND NOT Description LIKE '%VPN%' `
													AND NOT Description LIKE '%Virtual%' `
                                                    AND NOT Description LIKE '%Bluetooth%'"
													
 
 # Loop through each phsyical adapter found
foreach ($nic in $nics)
  {
   
  $nicName = $nic.Name
   
   Write-Host "--- Enable `"Allow the computer to turn off this device to save power`" on $nicName ---"
   $nicPower = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi | where {$_.instancename -match [regex]::escape($nic.PNPDeviceID) }
   $nicPower.Enable = $True
   $nicPower.psbase.Put()
    
   Write-Host "--- Enable `"Allow this device to wake the computer`" on $nicName ---"
   $nicPowerWake = Get-WmiObject MSPower_DeviceWakeEnable -Namespace root\wmi | where {$_.instancename -match [regex]::escape($nic.PNPDeviceID) }
   $nicPowerWake.Enable = $True
   $nicPowerWake.psbase.Put()
    
   Write-Host "--- Enable `"Only allow a magic packet to wake the computer`" on $nicName ---"
   $nicMagicPacket = Get-WmiObject MSNdis_DeviceWakeOnMagicPacketOnly -Namespace root\wmi | where {$_.instancename -match [regex]::escape($nic.PNPDeviceID) }
   $nicMagicPacket.EnableWakeOnMagicPacketOnly = $True
   $nicMagicPacket.psbase.Put()
  }
 
 #Disable EEE
 Set-NetAdapterAdvancedProperty -Name $nics -DisplayName "Energy-Efficient Ethernet" -DisplayValue "Disabled"


