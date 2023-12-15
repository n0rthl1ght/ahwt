@echo off

secedit /configure /db %windir%\security\Database\local_sec.db /areas securitypolicy regkeys /cfg hisecdc_v9.inf

echo Group Policies imported.

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager" /v "SafeDllSearchMode" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters" /v "SynAttackProtect" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\RasMan\Parameters" /v "DisableSavePassword" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters" /v "DisableIPSourceRouting" /t REG_DWORD /d 2 /f

reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /t REG_SZ /d 0 /f

reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxConnectResponseRetransmissions" /t REG_DWORD /d 2 /f

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Security" /v "WarningLevel" /t REG_DWORD /d 90 /f

reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxDataRetransmissions" /t REG_DWORD /d 3 /f

reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableICMPRedirect" /t REG_DWORD /d 0 /f

reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters" /v "KeepAliveTime" /t REG_DWORD /d 300000 /f

reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters" /v "PerformRouterDiscovery" /t REG_DWORD /d 0 /f

reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableDeadGWDetect" /t REG_DWORD /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "ScreenSaverGracePeriod" /t REG_SZ /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\Autorun.inf" /v "(Default))" /t REG_SZ /d "@SYS:DoesNotExist" /f

reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "allocatedasd" /t REG_SZ /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Terminal Services" /v "fResetBroken" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\system" /v "DisableBkGndGroupPolicy" /t REG_DWORD /d 0 /f

reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\SubSystems\Posix" /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\System\Power" /v "PromptPasswordOnResume" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Lsa" /v "Notification Packages" /t REG_MULTI_SZ /d "scecli, EnPasFltV2x86" /f

reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Netbt\Parameters" /v "NoNameReleaseOnDemand" /t REG_DWORD /d 1 /f

echo Security options has been configured.


reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMPTRAP" /v "Start" /t REG_DWORD /d 3 /f


reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SharedAccess" /v "Start" /t REG_DWORD /d 3 /f

echo System services has been configured.


reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Rpc" /v "RestrictRemoteClients" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Rpc" /v "EnableAuthEpResolution" /t REG_DWORD /d 1 /f

echo RPC has been configured.


reg add "HKEY_LOCAL_MACHINE\Software\policies\Microsoft\Windows NT\Terminal Services" /v "fAllowToGetHelp" /t REG_DWORD /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\policies\Microsoft\Windows NT\Terminal Services" /v "fAllowUnsolicited" /t REG_DWORD /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\policies\Microsoft\Windows NT\Terminal Services" /v "Shadow" /t REG_DWORD /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\policies\Microsoft\Windows NT\Terminal Services" /v "fEncryptRPCTraffic" /t REG_DWORD /d 1 /f

echo Remote Assistance has been configured.


reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Printers" /v "DisableWebPnPDownload" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\DriverSearching" /v "DontSearchWindowsUpdate" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoPublishingWizard" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoWebServices" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Printers" /v "DisableHTTPPrinting" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Printers" /v "KMPrintersAreBlocked" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Messenger\Client" /v "CEIP" /t REG_DWORD /d 2 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\SearchCompanion" /v "DisableContentFileUpdates" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Internet Explorer\Feeds" /v "DisableEnclosureDownload" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "PreXPSP2ShellProtocolBehavior" /t REG_DWORD /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Network Connections" /v "NC_ShowSharedAccessUI" /t REG_DWORD /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Network Connections" /v "NC_AllowNetBridge_NLA" /t REG_DWORD /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Peernet" /v "Disabled" /t REG_DWORD /d 1 /f

echo Internet Communications has been configured.


reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "DisableLocalMachineRun" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "DisableLocalMachineRunOnce" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoInternetOpenWith" /t REG_DWORD /d 1 /f

echo Logon has been configured.


reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Installer" /v "AlwaysInstallElevated" /t REG_DWORD /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Installer" /v "EnableUserControl" /t REG_DWORD /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Installer" /v "SafeForScripting" /t REG_DWORD /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Installer" /v "DisableLUAPatching" /t REG_DWORD /d 1 /f

echo Windows Installer has been configured.


reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "DisablePasswordSaving" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fDisableCdm" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fPromptForPassword" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "fReconnectSame" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "MaxIdleTime" /t REG_DWORD /d 900000 /f

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "MinEncryptionLevel" /t REG_DWORD /d 3 /f

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "DeleteTempDirsOnExit" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "MinEncryptionLevel" /t REG_DWORD /d 3 /f

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v "PerSessionTempDir" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDriveTypeAutoRun" /t REG_DWORD /d 255 /f

echo RDP has been configured.


reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\PCHealth\ErrorReporting" /v "IncludeKernelFaults" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\PCHealth\ErrorReporting" /v "ShowUI" /t REG_DWORD /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\PCHealth\ErrorReporting" /v "DoReport" /t REG_DWORD /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Conferencing" /v "NoRDS" /t REG_DWORD /d 1 /f

echo Windows Reports has been configured.


reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}" /v "NoGPOListChanges" /t REG_DWORD /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Messenger\Client" /v "PreventRun" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\System\Power" /v "PromptPasswordOnResume" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\system" /v "LogonType" /t REG_DWORD /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "HideZoneInfoOnProperties" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "ScanWithAntiVirus" /t REG_DWORD /d 3 /f

reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /t REG_DWORD /d 2 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsMovieMaker" /v "WebPublish" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsMovieMaker" /v "CodecDownload" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsMovieMaker" /v "Webhelp" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsMediaPlayer" /v "DisableAutoupdate" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsMediaPlayer" /v "PreventCodecDownload" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\WindowsMediaPlayer" /v "GroupPrivacyAcceptance" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\W32Time\Parameters" /v "Type" /t REG_SZ /d "NTP" /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\W32Time\Parameters" /v "NTPServer" /t REG_SZ /d "address" /f

reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Allocatefloppies" /t REG_SZ /d 0 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Registration Wizard Control" /v "NoRegistration" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Internet Connection Wizard" /v "ExitOnMSICW" /t REG_DWORD /d 1 /f

reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\EventViewer" /v "MicrosoftEventVwrDisableLinks" /t REG_DWORD /d 0 /f

echo Other group policies has been configured.


:: Отключить прием ICMP-редиректов 
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableICMPRedirect" /t REG_DWORD /d "0" /f
:: Отключить маршрутизацию источника
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DisableIPSourceRouting" /t REG_DWORD /d "2" /f
:: защита от SYN-флуда
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "SynAttackProtect" /t REG_DWORD /d "1" /f
:: TCP/IP харденинг
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxConnectResponseRetransmissions" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxDataRetransmissions" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxHalfOpen" /t REG_DWORD /d "100" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxPortsExhausted" /t REG_DWORD /d "5" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxUserPort" /t REG_DWORD /d "65534" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpNumConnections" /t REG_DWORD /d "16777214" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d "30" /f
::  UDP харденинг
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "UdpMaxPortsExhausted" /t REG_DWORD /d "5" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "UdpMaxUserPort" /t REG_DWORD /d "65534" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "UdpNumConnections" /t REG_DWORD /d "16777214" /f
:: Enable Windows Firewall
netsh firewall set opmode enable
::отрубить удаленного асист
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v fAllowToGetHelp /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v fAllowFullControl /t REG_DWORD /d 0 /f
reg add "HKLM\System\CurrentControlSet\Control\Remote Assistance" /v fAllowToGetHelp /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\AuthorizedApplications\List" /v "C:\WINDOWS\system32\sessmgr.exe" /t REG_SZ /d "C:\WINDOWS\system32\sessmgr.exe:*:Disabled:@xpsp2res.dll,-22019" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\AuthorizedApplications\List" /v "C:\WINDOWS\system32\sessmgr.exe" /t REG_SZ /d "C:\WINDOWS\system32\sessmgr.exe:*:Disabled:@xpsp2res.dll,-22019" /f

::Диагностика сети
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\AuthorizedApplications\List" /v "C:\WINDOWS\Network Diagnostic\xpnetdiag.exe" /t REG_SZ /d "C:\WINDOWS\Network Diagnostic\xpnetdiag.exe:*:Enabled:@xpsp3res.dll,-20000" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\AuthorizedApplications\List" /v "C:\WINDOWS\Network Diagnostic\xpnetdiag.exe" /t REG_SZ /d "C:\WINDOWS\Network Diagnostic\xpnetdiag.exe:*:@xpsp3res.dll,-20000" /f

::TightVNC
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\AuthorizedApplications\List" /v "C:\Program Files\TightVNC\tvnserver.exe" /t REG_SZ /d "C:\Program Files\TightVNC\tvnserver.exe:*:Enabled:TightVNC" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\AuthorizedApplications\List" /v "C:\Program Files\TightVNC\tvnserver.exe" /t REG_SZ /d "C:\Program Files\TightVNC\tvnserver.exe:*:Enabled:TightVNC" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\AuthorizedApplications\List" /v "C:\Program Files\TightVNC\tvnviewer.exe" /t REG_SZ /d "C:\Program Files\TightVNC\tvnviewer.exe:*:Enabled:TightVNC" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\AuthorizedApplications\List" /v "C:\Program Files\TightVNC\tvnviewer.exe" /t REG_SZ /d "C:\Program Files\TightVNC\tvnviewer.exe:*:Enabled:TightVNC" /f
::ограничить возможность изменения настроек брандмауэра
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v EnableFirewall /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v DisableNotifications /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v DoNotAllowExceptions /t REG_DWORD /d 1 /f

::Включение логов фаерволла
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v LogDroppedPackets /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v LogSuccessfulConnections /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" /v LogDroppedPackets /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" /v LogSuccessfulConnections /t REG_DWORD /d 1 /f

echo Firewall has been configured.

echo Mission Accomplished! :)

pause
