@echo off
REM QRCode.bat - Ejecutor del generador QR con PowerShell 7
REM Uso: QRCode.bat [parametros]

setlocal enabledelayedexpansion

REM Buscar PowerShell 7 en ubicaciones comunes
set "PWSH="

if exist "C:\Program Files\PowerShell\7\pwsh.exe" (
    set "PWSH=C:\Program Files\PowerShell\7\pwsh.exe"
) else if exist "C:\Users\%USERNAME%\AppData\Local\Microsoft\WindowsApps\pwsh.exe" (
    set "PWSH=C:\Users\%USERNAME%\AppData\Local\Microsoft\WindowsApps\pwsh.exe"
) else (
    echo Error: PowerShell 7 no encontrado
    echo Instala con: winget install Microsoft.PowerShell
    exit /b 1
)

REM Ejecutar QRCode.ps1 con PowerShell 7
"!PWSH!" -NoProfile -File ".\QRCode.ps1" %*

endlocal
