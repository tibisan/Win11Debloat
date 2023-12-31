@echo DISABLE IPV6 System Wide

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents /t REG_DWORD /d 255 /f

@echo Rearm Windows Firewall by zeroing the default rules

REG DELETE "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /f
REG add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /f

PowerShell -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0Win11Debloat.ps1""' -Verb RunAs}"

cls
@ECHO Please wait while we uninstall OneDrive

set x86="%SYSTEMROOT%\System32\OneDriveSetup.exe"
set x64="%SYSTEMROOT%\SysWOW64\OneDriveSetup.exe"

echo Closing OneDrive process.
echo.
taskkill /f /im OneDrive.exe > NUL 2>&1
ping 127.0.0.1 -n 5 > NUL 2>&1

echo Uninstalling OneDrive.
echo.
if exist %x64% (
%x64% /uninstall
) else (
%x86% /uninstall
)
ping 127.0.0.1 -n 5 > NUL 2>&1

echo Removing OneDrive leftovers.
echo.
rd "%USERPROFILE%\OneDrive" /Q /S > NUL 2>&1
rd "C:\OneDriveTemp" /Q /S > NUL 2>&1
rd "%LOCALAPPDATA%\Microsoft\OneDrive" /Q /S > NUL 2>&1
rd "%PROGRAMDATA%\Microsoft OneDrive" /Q /S > NUL 2>&1

echo Removing OneDrive from the Explorer Side Panel.
echo.
REG DELETE "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f > NUL 2>&1
REG DELETE "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f > NUL 2>&1

@ECHO Please wait while we install Brave Browser

PowerShell -ExecutionPolicy Bypass -Command "& {Invoke-WebRequest 'https://brave-browser-downloads.s3.brave.com/latest/brave_installer-x64.exe'  -OutFile $env:temp\brave_installer-x64.exe}"
PowerShell -ExecutionPolicy Bypass -Command "& {Start-Process -FilePath  $env:temp\brave_installer-x64.exe -ArgumentList '--install --silent --system-level' -Wait -Verb RunAs}"


PowerShell -ExecutionPolicy Bypass -Command "& {Invoke-WebRequest 'https://1111-releases.cloudflareclient.com/windows/Cloudflare_WARP_Release-x64.msi'  -OutFile $env:temp\Cloudflare_WARP_Release-x64.msi}"
PowerShell -ExecutionPolicy Bypass -Command "& {Start-Process -FilePath msiexec.exe -ArgumentList '/i $env:temp\Cloudflare_WARP_Release-x64.msi  /qn /norestart' -Wait -Verb RunAs}"


https://1111-releases.cloudflareclient.com/windows/Cloudflare_WARP_Release-x64.msi

@ECHO Please wait while we install HyperV
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

