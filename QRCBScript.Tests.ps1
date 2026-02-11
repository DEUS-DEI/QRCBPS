#Requires -Version 5.1

Describe "QR Code Generator - Robustness & Extensions" {
    BeforeAll {
        $ScriptPath = Join-Path $PSScriptRoot "QRCBScript.ps1"
        if (-not (Test-Path $ScriptPath)) {
            throw "QRCBScript.ps1 no encontrado en $ScriptPath"
        }
        # Pester 3.4.0 syntax: Should Be, Should Match, Should Throw
    }

    Context "Robustness - Set-StrictMode" {
        It "Debe ejecutar el script sin errores básicos de sintaxis o variables (StrictMode 2.0)" {
            { & $ScriptPath -Data "Test" -ShowConsole:$false -OutputPath "" } | Should Not Throw
        }
    }

    Context "Extensions - Data URI" {
        It "Debe generar una salida Base64 válida cuando -DataUri está presente" {
            $output = & $ScriptPath -Data "https://trae.ai" -DataUri -ShowConsole:$false
            $output | Should Match "data:image/png;base64,"
        }
    }

    Context "Extensions - ANSI Render" {
        It "ShowConsole no debe lanzar errores con diferentes tamaños de QR" {
            { & $ScriptPath -Data "Small" -ShowConsole -OutputPath "" } | Should Not Throw
            { & $ScriptPath -Data "Un texto mucho más largo para forzar una versión superior del código QR" -ShowConsole -OutputPath "" } | Should Not Throw
        }
    }

    Context "Extensions - EPS Format" {
        It "Debe crear un archivo .eps con cabecera PostScript válida" {
            $testEps = Join-Path $PSScriptRoot "test_unit.eps"
            if (Test-Path $testEps) { Remove-Item $testEps }
            
            & $ScriptPath -Data "EPS Test" -OutputPath $testEps | Out-Null
            
            (Test-Path $testEps) | Should Be $true
            $content = Get-Content $testEps -Raw
            $content | Should Match "%!PS-Adobe-3.0 EPSF-3.0"
            
            Remove-Item $testEps
        }
    }

    Context "Extensions - PBM/PGM Format" {
        It "Debe crear archivos PBM/PGM con cabeceras Netpbm válidas" {
            $testPbm = Join-Path $PSScriptRoot "test_unit.pbm"
            $testPgm = Join-Path $PSScriptRoot "test_unit.pgm"
            if (Test-Path $testPbm) { Remove-Item $testPbm }
            if (Test-Path $testPgm) { Remove-Item $testPgm }

            & $ScriptPath -Data "PBM Test" -OutputPath $testPbm | Out-Null
            & $ScriptPath -Data "PGM Test" -OutputPath $testPgm | Out-Null

            (Test-Path $testPbm) | Should Be $true
            (Test-Path $testPgm) | Should Be $true

            $pbmHeader = Get-Content $testPbm -TotalCount 1
            $pgmHeader = Get-Content $testPgm -TotalCount 1
            $pbmHeader | Should Be "P1"
            $pgmHeader | Should Be "P2"

            Remove-Item $testPbm
            Remove-Item $testPgm
        }
    }

    Context "Extensions - Payloads y Validaciones" {
        BeforeAll {
            . $ScriptPath -Data "Init" -ShowConsole:$false -OutputPath "" | Out-Null
        }

        It "Debe generar payloads MailTo, SMS, Tel, WhatsApp y Geo válidos" {
            (New-MailTo -To "a@b.com" -Subject "Hola" -Body "Mensaje") | Should Match "^mailto:"
            (New-Sms -Number "+34600000000" -Message "Hola") | Should Match "^sms:\+"
            (New-Tel -Number "+34600000000") | Should Match "^tel:\+"
            (New-WhatsApp -Number "+34600000000" -Message "Hola") | Should Match "^https://wa\.me/"
            (New-Geo -Latitude 40.4168 -Longitude -3.7038) | Should Match "^geo:"
        }

        It "Debe generar eventos vEvent y vCalendar válidos" {
            $ve = New-vEvent -Summary "Reunión" -Start (Get-Date "2026-02-15 10:00") -End (Get-Date "2026-02-15 11:00")
            $vc = New-VCalendarEvent -Summary "Reunión" -Start (Get-Date "2026-02-15 10:00") -End (Get-Date "2026-02-15 11:00")
            $ve | Should Match "BEGIN:VEVENT"
            $vc | Should Match "BEGIN:VCALENDAR"
        }

        It "Debe generar URI de pago y validar formatos básicos" {
            (New-PaymentUri -Scheme "upi" -Address "id@banco" -Params @{ am = "10.50"; cu = "INR" }) | Should Match "^upi:"
            (Test-Email "test@ejemplo.com") | Should Be $true
            (Test-UrlStrict "https://ejemplo.com") | Should Be $true
            (Test-PhoneE164 "+34600000000") | Should Be $true
            (Test-Domain "ejemplo.com") | Should Be $true
        }
    }

    Context "Core - Type Safety" {
        It "El script principal debe manejar correctamente la generación de QR con tipos estrictos" {
            { & $ScriptPath -Data "TypeTest" -OutputPath "test.png" } | Should Not Throw
        }
    }
}
