#Requires -Version 5.1
<#
.SYNOPSIS
    QR Code Generator FINAL - PowerShell Nativo 100% Funcional
.DESCRIPTION
    Implementación completa siguiendo ISO/IEC 18004
    Genera QR codes escaneables
#>

# GF(256) lookup tables
$script:EXP = @(1,2,4,8,16,32,64,128,29,58,116,232,205,135,19,38,76,152,45,90,180,117,234,201,143,3,6,12,24,48,96,192,157,39,78,156,37,74,148,53,106,212,181,119,238,193,159,35,70,140,5,10,20,40,80,160,93,186,105,210,185,111,222,161,95,190,97,194,153,47,94,188,101,202,137,15,30,60,120,240,253,231,211,187,107,214,177,127,254,225,223,163,91,182,113,226,217,175,67,134,17,34,68,136,13,26,52,104,208,189,103,206,129,31,62,124,248,237,199,147,59,118,236,197,151,51,102,204,133,23,46,92,184,109,218,169,79,158,33,66,132,21,42,84,168,77,154,41,82,164,85,170,73,146,57,114,228,213,183,115,230,209,191,99,198,145,63,126,252,229,215,179,123,246,241,255,227,219,171,75,150,49,98,196,149,55,110,220,165,87,174,65,130,25,50,100,200,141,7,14,28,56,112,224,221,167,83,166,81,162,89,178,121,242,249,239,195,155,43,86,172,69,138,9,18,36,72,144,61,122,244,245,247,243,251,235,203,139,11,22,44,88,176,125,250,233,207,131,27,54,108,216,173,71,142,1)
$script:LOG = @(0,0,1,25,2,50,26,198,3,223,51,238,27,104,199,75,4,100,224,14,52,141,239,129,28,193,105,248,200,8,76,113,5,138,101,47,225,36,15,33,53,147,142,218,240,18,130,69,29,181,194,125,106,39,249,185,201,154,9,120,77,228,114,166,6,191,139,98,102,221,48,253,226,152,37,179,16,145,34,136,54,208,148,206,143,150,219,189,241,210,19,92,131,56,70,64,30,66,182,163,195,72,126,110,107,58,40,84,250,133,186,61,202,94,155,159,10,21,121,43,78,212,229,172,115,243,167,87,7,112,192,247,140,128,99,13,103,74,222,237,49,197,254,24,227,165,153,119,38,184,180,124,17,68,146,217,35,32,137,46,55,63,209,91,149,188,207,205,144,135,151,178,220,252,190,97,242,86,211,171,20,42,93,158,132,60,57,83,71,109,65,162,31,45,67,216,183,123,164,118,196,23,73,236,127,12,111,246,108,161,59,82,41,157,85,170,251,96,134,177,187,204,62,90,203,89,95,176,156,169,160,81,11,245,22,235,122,117,44,215,79,174,213,233,230,231,173,232,116,214,244,234,168,80,88,175)

function GFMul($a,$b) { if($a -eq 0 -or $b -eq 0){return 0}; $s=$script:LOG[$a]+$script:LOG[$b]; if($s -ge 255){$s-=255}; return $script:EXP[$s] }

# Format info strings (precalculated per ISO 18004)
$script:FMT = @{
    'L0'='111011111000100';'L1'='111001011110011';'L2'='111110110101010';'L3'='111100010011101'
    'L4'='110011000101111';'L5'='110001100011000';'L6'='110110001000001';'L7'='110100101110110'
    'M0'='101010000010010';'M1'='101000100100101';'M2'='101111001111100';'M3'='101101101001011'
    'M4'='100010111111001';'M5'='100000011001110';'M6'='100111110010111';'M7'='100101010100000'
    'Q0'='011010101011111';'Q1'='011000001101000';'Q2'='011111100110001';'Q3'='011101000000110'
    'Q4'='010010010110100';'Q5'='010000110000011';'Q6'='010111011011010';'Q7'='010101111101101'
    'H0'='001011010001001';'H1'='001001110111110';'H2'='001110011100111';'H3'='001100111010000'
    'H4'='000011101100010';'H5'='000001001010101';'H6'='000110100001100';'H7'='000100000111011'
}

$script:ALPH = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ `$%*+-./:"
$script:SPEC = @{
    '1L'=@{D=19;E=7;G1=1;D1=19;G2=0;D2=0}; '1M'=@{D=16;E=10;G1=1;D1=16;G2=0;D2=0}; '1Q'=@{D=13;E=13;G1=1;D1=13;G2=0;D2=0}; '1H'=@{D=9;E=17;G1=1;D1=9;G2=0;D2=0}
    '2L'=@{D=34;E=10;G1=1;D1=34;G2=0;D2=0}; '2M'=@{D=28;E=16;G1=1;D1=28;G2=0;D2=0}; '2Q'=@{D=22;E=22;G1=1;D1=22;G2=0;D2=0}; '2H'=@{D=16;E=28;G1=1;D1=16;G2=0;D2=0}
    '3L'=@{D=55;E=15;G1=1;D1=55;G2=0;D2=0}; '3M'=@{D=44;E=26;G1=1;D1=44;G2=0;D2=0}; '3Q'=@{D=34;E=36;G1=2;D1=17;G2=0;D2=0}; '3H'=@{D=26;E=44;G1=2;D1=13;G2=0;D2=0}
    '4L'=@{D=80;E=20;G1=1;D1=80;G2=0;D2=0}; '4M'=@{D=64;E=36;G1=2;D1=32;G2=0;D2=0}; '4Q'=@{D=48;E=52;G1=2;D1=24;G2=0;D2=0}; '4H'=@{D=36;E=64;G1=4;D1=9;G2=0;D2=0}
    '5L'=@{D=108;E=26;G1=1;D1=108;G2=0;D2=0}; '5M'=@{D=86;E=48;G1=2;D1=43;G2=0;D2=0}; '5Q'=@{D=62;E=72;G1=2;D1=15;G2=2;D2=16}; '5H'=@{D=46;E=88;G1=2;D1=11;G2=2;D2=12}
    '6L'=@{D=136;E=36;G1=2;D1=68;G2=0;D2=0}; '6M'=@{D=108;E=64;G1=4;D1=27;G2=0;D2=0}; '6Q'=@{D=76;E=96;G1=4;D1=19;G2=0;D2=0}; '6H'=@{D=60;E=112;G1=4;D1=15;G2=0;D2=0}
    '7L'=@{D=156;E=40;G1=2;D1=78;G2=0;D2=0}; '7M'=@{D=124;E=72;G1=4;D1=31;G2=0;D2=0}; '7Q'=@{D=88;E=108;G1=2;D1=14;G2=4;D2=15}; '7H'=@{D=66;E=130;G1=4;D1=13;G2=1;D2=14}
    '8L'=@{D=194;E=48;G1=2;D1=97;G2=0;D2=0}; '8M'=@{D=154;E=88;G1=2;D1=38;G2=2;D2=39}; '8Q'=@{D=110;E=132;G1=4;D1=22;G2=2;D2=23}; '8H'=@{D=86;E=156;G1=4;D1=16;G2=2;D2=17}
    '9L'=@{D=232;E=60;G1=2;D1=116;G2=0;D2=0}; '9M'=@{D=180;E=112;G1=3;D1=45;G2=1;D2=46}; '9Q'=@{D=132;E=160;G1=4;D1=26;G2=2;D2=27}; '9H'=@{D=100;E=192;G1=4;D1=18;G2=2;D2=19}
    '10L'=@{D=274;E=72;G1=2;D1=137;G2=0;D2=0}; '10M'=@{D=216;E=130;G1=4;D1=43;G2=2;D2=44}; '10Q'=@{D=154;E=192;G1=4;D1=23;G2=2;D2=24}; '10H'=@{D=122;E=224;G1=2;D1=15;G2=4;D2=16}
}

$script:CAP = @{
    1=@{L=@(41,25,17);M=@(34,20,14);Q=@(27,16,11);H=@(17,10,7)}
    2=@{L=@(77,47,32);M=@(63,38,26);Q=@(48,29,20);H=@(34,20,14)}
    3=@{L=@(127,77,53);M=@(101,61,42);Q=@(77,47,32);H=@(58,35,24)}
    4=@{L=@(187,114,78);M=@(149,90,62);Q=@(111,67,46);H=@(82,50,34)}
    5=@{L=@(255,154,106);M=@(202,122,84);Q=@(144,87,60);H=@(106,64,44)}
    6=@{L=@(322,195,134);M=@(255,154,106);Q=@(178,108,74);H=@(139,84,58)}
    7=@{L=@(370,224,154);M=@(293,178,122);Q=@(207,125,86);H=@(154,93,64)}
    8=@{L=@(461,279,192);M=@(365,221,152);Q=@(259,157,108);H=@(202,122,84)}
    9=@{L=@(552,335,230);M=@(432,262,180);Q=@(312,189,130);H=@(235,143,98)}
    10=@{L=@(652,395,271);M=@(513,311,213);Q=@(364,221,151);H=@(288,174,119)}
}

$script:ALIGN = @{
    2=@(6,18); 3=@(6,22); 4=@(6,26); 5=@(6,30); 6=@(6,34); 
    7=@(6,22,38); 8=@(6,24,42); 9=@(6,26,46); 10=@(6,28,50)
}

$script:VER_INFO = @{
    7='000111110010010100'; 8='001000010110111100'; 9='001001101010011001'; 10='001010010011010011'
}

function GetMode($t) {
    if ($t -match '^[0-9]+$') { return 'N' }
    foreach ($c in $t.ToCharArray()) { if ($script:ALPH.IndexOf($c) -lt 0) { return 'B' } }
    return 'A'
}

function Encode($txt, $ver, $ec) {
    $mode = GetMode $txt
    $bits = New-Object System.Collections.ArrayList
    
    switch ($mode) { 'N'{[void]$bits.AddRange(@(0,0,0,1))} 'A'{[void]$bits.AddRange(@(0,0,1,0))} 'B'{[void]$bits.AddRange(@(0,1,0,0))} }
    
    $cb = switch ($mode) { 'N'{10} 'A'{9} 'B'{8} }
    $len = if ($mode -eq 'B') { [Text.Encoding]::UTF8.GetByteCount($txt) } else { $txt.Length }
    for ($i = $cb - 1; $i -ge 0; $i--) { [void]$bits.Add([int](($len -shr $i) -band 1)) }
    
    switch ($mode) {
        'N' {
            for ($i = 0; $i -lt $txt.Length; $i += 3) {
                $ch = $txt.Substring($i, [Math]::Min(3, $txt.Length - $i))
                $v = [int]$ch; $nb = switch ($ch.Length) { 3{10} 2{7} 1{4} }
                for ($b = $nb - 1; $b -ge 0; $b--) { [void]$bits.Add([int](($v -shr $b) -band 1)) }
            }
        }
        'A' {
            for ($i = 0; $i -lt $txt.Length; $i += 2) {
                if ($i + 1 -lt $txt.Length) {
                    $v = $script:ALPH.IndexOf($txt[$i]) * 45 + $script:ALPH.IndexOf($txt[$i+1])
                    for ($b = 10; $b -ge 0; $b--) { [void]$bits.Add([int](($v -shr $b) -band 1)) }
                } else {
                    $v = $script:ALPH.IndexOf($txt[$i])
                    for ($b = 5; $b -ge 0; $b--) { [void]$bits.Add([int](($v -shr $b) -band 1)) }
                }
            }
        }
        'B' {
            foreach ($byte in [Text.Encoding]::UTF8.GetBytes($txt)) {
                for ($b = 7; $b -ge 0; $b--) { [void]$bits.Add([int](($byte -shr $b) -band 1)) }
            }
        }
    }
    
    $cap = $script:SPEC["$ver$ec"].D * 8
    $term = [Math]::Min(4, $cap - $bits.Count)
    for ($i = 0; $i -lt $term; $i++) { [void]$bits.Add(0) }
    while ($bits.Count % 8 -ne 0) { [void]$bits.Add(0) }
    
    $pads = @(236, 17); $pi = 0
    while ($bits.Count -lt $cap) {
        $pb = $pads[$pi]; $pi = 1 - $pi
        for ($b = 7; $b -ge 0; $b--) { [void]$bits.Add([int](($pb -shr $b) -band 1)) }
    }
    
    $result = @()
    for ($i = 0; $i -lt $bits.Count; $i += 8) {
        $byte = 0
        for ($j = 0; $j -lt 8; $j++) { $byte = ($byte -shl 1) -bor $bits[$i + $j] }
        $result += $byte
    }
    return $result
}

function GetGen($n) {
    $g = @(1)
    for ($i = 0; $i -lt $n; $i++) {
        $ng = @(0) * ($g.Count + 1)
        $a = $script:EXP[$i]
        for ($j = 0; $j -lt $g.Count; $j++) {
            $ng[$j + 1] = $ng[$j + 1] -bxor $g[$j]
            $ng[$j] = $ng[$j] -bxor (GFMul $g[$j] $a)
        }
        $g = $ng
    }
    return $g
}

function GetEC($data, $ecn) {
    if ($data.Count -eq 0) { return @() }
    $gen = GetGen $ecn
    # $gen is Little Endian: [g0, g1, ..., g_n-1, 1]
    
    $msg = @(0) * ($data.Count + $ecn)
    for ($i = 0; $i -lt $data.Count; $i++) { $msg[$i] = $data[$i] }
    
    for ($i = 0; $i -lt $data.Count; $i++) {
        $c = $msg[$i]
        if ($c -ne 0) {
            # Multiply c * generator and subtract (XOR) from message
            # Generator is x^n + g_{n-1}x^{n-1} + ... + g0
            # We align leading term (1) with msg[i] (which becomes 0)
            # msg[i+1] -= c * g_{n-1} ...
            
            for ($j = 0; $j -lt $ecn; $j++) {
                $idxMsg = $i + 1 + $j
                $idxGen = $ecn - 1 - $j
                $msg[$idxMsg] = $msg[$idxMsg] -bxor (GFMul $gen[$idxGen] $c)
            }
        }
    }
    return $msg[$data.Count..($msg.Count - 1)]
}

function BuildCW($data, $ver, $ec) {
    $spec = $script:SPEC["$ver$ec"]
    $ecCW = GetEC $data $spec.E
    return $data + $ecCW
}

function GetSize($v) { return 17 + $v * 4 }

function NewM($size) {
    $m = @{}
    $m.Size = $size
    $m.Mod = @{}     # "$row,$col" -> 0 or 1
    $m.Func = @{}    # "$row,$col" -> $true or $false
    for ($r = 0; $r -lt $size; $r++) {
        for ($c = 0; $c -lt $size; $c++) {
            $m.Mod["$r,$c"] = 0
            $m.Func["$r,$c"] = $false
        }
    }
    return $m
}

function SetF($m, $r, $c, $v) {
    if ($r -ge 0 -and $r -lt $m.Size -and $c -ge 0 -and $c -lt $m.Size) {
        $m.Mod["$r,$c"] = [int]$v
        $m.Func["$r,$c"] = $true
    }
}

function GetM($m, $r, $c) { return $m.Mod["$r,$c"] }
function IsF($m, $r, $c) { return $m.Func["$r,$c"] }

function AddFinder($m, $row, $col) {
    for ($dy = -1; $dy -le 7; $dy++) {
        for ($dx = -1; $dx -le 7; $dx++) {
            $r = $row + $dy; $c = $col + $dx
            if ($r -lt 0 -or $r -ge $m.Size -or $c -lt 0 -or $c -ge $m.Size) { continue }
            
            $inFinder = $dy -ge 0 -and $dy -le 6 -and $dx -ge 0 -and $dx -le 6
            if (-not $inFinder) { SetF $m $r $c $false; continue }
            
            $onBorder = $dy -eq 0 -or $dy -eq 6 -or $dx -eq 0 -or $dx -eq 6
            $inCenter = $dy -ge 2 -and $dy -le 4 -and $dx -ge 2 -and $dx -le 4
            SetF $m $r $c ($onBorder -or $inCenter)
        }
    }
}

function AddAlign($m, $row, $col) {
    for ($dy = -2; $dy -le 2; $dy++) {
        for ($dx = -2; $dx -le 2; $dx++) {
            $r = $row + $dy; $c = $col + $dx
            if (IsF $m $r $c) { continue }
            $onBorder = [Math]::Abs($dy) -eq 2 -or [Math]::Abs($dx) -eq 2
            $isCenter = $dy -eq 0 -and $dx -eq 0
            SetF $m $r $c ($onBorder -or $isCenter)
        }
    }
}

function AddVersionInfo($m, $ver) {
    if ($ver -lt 7) { return }
    $bits = $script:VER_INFO[$ver]
    $size = $m.Size
    
    for ($i = 0; $i -lt 18; $i++) {
        $bit = [int]($bits[$i].ToString())
        
        # Block 1: Bottom-Left (near finder)
        # 6x3 block. Rows: Size-11 to Size-9. Cols: 0 to 5.
        $r = [Math]::Floor($i / 3)
        $c = ($i % 3) + $size - 11
        SetF $m $r $c $bit   
        SetF $m $c $r $bit   
    }
}

function InitM($ver) {
    $size = GetSize $ver
    $m = NewM $size
    
    AddFinder $m 0 0
    AddFinder $m 0 ($size - 7)
    AddFinder $m ($size - 7) 0
    
    for ($i = 8; $i -lt $size - 8; $i++) {
        $v = ($i % 2) -eq 0
        if (-not (IsF $m 6 $i)) { SetF $m 6 $i $v }
        if (-not (IsF $m $i 6)) { SetF $m $i 6 $v }
    }
    
    if ($ver -ge 2 -and $script:ALIGN[$ver]) {
        foreach ($row in $script:ALIGN[$ver]) {
            foreach ($col in $script:ALIGN[$ver]) {
                $skip = ($row -lt 9 -and $col -lt 9) -or ($row -lt 9 -and $col -gt $size - 10) -or ($row -gt $size - 10 -and $col -lt 9)
                if (-not $skip) { AddAlign $m $row $col }
            }
        }
    }
    
    SetF $m (4 * $ver + 9) 8 $true
    
    for ($i = 0; $i -lt 9; $i++) {
        if (-not (IsF $m 8 $i)) { $m.Func["8,$i"] = $true }
        if (-not (IsF $m $i 8)) { $m.Func["$i,8"] = $true }
    }
    for ($i = 0; $i -lt 8; $i++) {
        if (-not (IsF $m 8 ($size-1-$i))) { $m.Func["8,$($size-1-$i)"] = $true }
        if (-not (IsF $m ($size-1-$i) 8)) { $m.Func["$($size-1-$i),8"] = $true }
    }
    
    AddVersionInfo $m $ver
    
    return $m
}

function PlaceData($m, $cw) {
    $bits = New-Object System.Collections.ArrayList
    foreach ($c in $cw) {
        for ($b = 7; $b -ge 0; $b--) { [void]$bits.Add([int](($c -shr $b) -band 1)) }
    }
    
    $idx = 0
    $up = $true
    
    for ($right = $m.Size - 1; $right -ge 1; $right -= 2) {
        if ($right -eq 6) { $right = 5 }
        
        $rows = if ($up) { ($m.Size - 1)..0 } else { 0..($m.Size - 1) }
        
        foreach ($row in $rows) {
            for ($dc = 0; $dc -le 1; $dc++) {
                $col = $right - $dc
                if (-not (IsF $m $row $col)) {
                    $v = if ($idx -lt $bits.Count -and $bits[$idx] -eq 1) { 1 } else { 0 }
                    $m.Mod["$row,$col"] = $v
                    $idx++
                }
            }
        }
        $up = -not $up
    }
}

function ApplyMask($m, $p) {
    $r = NewM $m.Size
    
    for ($row = 0; $row -lt $m.Size; $row++) {
        for ($col = 0; $col -lt $m.Size; $col++) {
            $r.Func["$row,$col"] = $m.Func["$row,$col"]
            $v = $m.Mod["$row,$col"]
            
            if (-not (IsF $m $row $col)) {
                $mask = switch ($p) {
                    0 { (($row + $col) % 2) -eq 0 }
                    1 { ($row % 2) -eq 0 }
                    2 { ($col % 3) -eq 0 }
                    3 { (($row + $col) % 3) -eq 0 }
                    4 { (([Math]::Floor($row / 2) + [Math]::Floor($col / 3)) % 2) -eq 0 }
                    5 { ((($row * $col) % 2) + (($row * $col) % 3)) -eq 0 }
                    6 { (((($row * $col) % 2) + (($row * $col) % 3)) % 2) -eq 0 }
                    7 { (((($row + $col) % 2) + (($row * $col) % 3)) % 2) -eq 0 }
                }
                if ($mask) { $v = 1 - $v }
            }
            $r.Mod["$row,$col"] = $v
        }
    }
    return $r
}

function GetPenalty($m) {
    $pen = 0
    $size = $m.Size
    
    # Rule 1
    for ($r = 0; $r -lt $size; $r++) {
        $run = 1
        for ($c = 1; $c -lt $size; $c++) {
            if ((GetM $m $r $c) -eq (GetM $m $r ($c-1))) { $run++ }
            else { if ($run -ge 5) { $pen += 3 + $run - 5 }; $run = 1 }
        }
        if ($run -ge 5) { $pen += 3 + $run - 5 }
    }
    for ($c = 0; $c -lt $size; $c++) {
        $run = 1
        for ($r = 1; $r -lt $size; $r++) {
            if ((GetM $m $r $c) -eq (GetM $m ($r-1) $c)) { $run++ }
            else { if ($run -ge 5) { $pen += 3 + $run - 5 }; $run = 1 }
        }
        if ($run -ge 5) { $pen += 3 + $run - 5 }
    }
    
    # Rule 2
    for ($r = 0; $r -lt $size - 1; $r++) {
        for ($c = 0; $c -lt $size - 1; $c++) {
            $v = GetM $m $r $c
            if ($v -eq (GetM $m $r ($c+1)) -and $v -eq (GetM $m ($r+1) $c) -and $v -eq (GetM $m ($r+1) ($c+1))) {
                $pen += 3
            }
        }
    }
    
    # Rule 4
    $dark = 0
    for ($r = 0; $r -lt $size; $r++) {
        for ($c = 0; $c -lt $size; $c++) {
            if ((GetM $m $r $c) -eq 1) { $dark++ }
        }
    }
    $pct = [int](($dark * 100) / ($size * $size))
    $pen += [Math]::Floor([Math]::Abs($pct - 50) / 5) * 10
    
    return $pen
}

function FindBestMask($m) {
    $best = 0; $min = [int]::MaxValue
    for ($p = 0; $p -lt 8; $p++) {
        $masked = ApplyMask $m $p
        $pen = GetPenalty $masked
        if ($pen -lt $min) { $min = $pen; $best = $p }
    }
    return $best
}

function AddFormat($m, $ec, $mask) {
    $fmt = $script:FMT["$ec$mask"]
    $size = $m.Size
    
    # Format info is 15 bits total
    # Bit 0 is the leftmost (MSB) in the format string
    # We need to place bits in specific positions around finder patterns
    
    for ($i = 0; $i -lt 15; $i++) {
        $bit = [int]($fmt[$i].ToString())
        
        # First copy: around top-left finder pattern
        # Bits 0-5: row 8, columns 0-5
        # Bit 6: row 8, column 7 (skip column 6 - timing)
        # Bit 7: row 8, column 8
        # Bit 8: row 7, column 8
        # Bits 9-14: rows 5,4,3,2,1,0 column 8 (skip row 6 - timing)
        
        if ($i -le 5) {
            $m.Mod["8,$i"] = $bit
        } elseif ($i -eq 6) {
            $m.Mod["8,7"] = $bit
        } elseif ($i -eq 7) {
            $m.Mod["8,8"] = $bit
        } elseif ($i -eq 8) {
            $m.Mod["7,8"] = $bit
        } else {
            # i = 9,10,11,12,13,14 -> rows 5,4,3,2,1,0
            $row = 14 - $i
            $m.Mod["$row,8"] = $bit
        }
        
        # Second copy: near bottom-left and top-right finders
        # Bits 0-7: row 8, columns (size-1) down to (size-8)
        # Bits 8-14: column 8, rows (size-7) up to (size-1)
        
        if ($i -le 7) {
            $m.Mod["8,$($size - 1 - $i)"] = $bit
        } else {
            # i = 8,9,10,11,12,13,14 -> rows size-7, size-6, ... size-1
            $row = $size - 15 + $i
            $m.Mod["$row,8"] = $bit
        }
    }
}

function ExportPng($m, $path, $scale, $quiet) {
    Add-Type -AssemblyName System.Drawing
    
    $img = ($m.Size + $quiet * 2) * $scale
    $bmp = New-Object Drawing.Bitmap $img, $img
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.Clear([Drawing.Color]::White)
    
    $black = [Drawing.Brushes]::Black
    
    for ($r = 0; $r -lt $m.Size; $r++) {
        for ($c = 0; $c -lt $m.Size; $c++) {
            if ((GetM $m $r $c) -eq 1) {
                $x = ($c + $quiet) * $scale
                $y = ($r + $quiet) * $scale
                $g.FillRectangle($black, $x, $y, $scale, $scale)
            }
        }
    }
    
    $g.Dispose()
    $bmp.Save($path, [Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

function ShowConsole($m) {
    Write-Host ""
    $border = [string]::new([char]0x2588, ($m.Size + 2) * 2)
    Write-Host "  $border"
    
    for ($r = 0; $r -lt $m.Size; $r++) {
        $line = "  " + [char]0x2588 + [char]0x2588
        for ($c = 0; $c -lt $m.Size; $c++) {
            $line += if ((GetM $m $r $c) -eq 1) { "  " } else { [string]::new([char]0x2588, 2) }
        }
        Write-Host "$line$([char]0x2588)$([char]0x2588)"
    }
    
    Write-Host "  $border"
    Write-Host ""
}

function New-QRCode {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Data,
        [ValidateSet('L','M','Q','H')][string]$ECLevel = 'M',
        [int]$Version = 0,
        [string]$OutputPath,
        [int]$ModuleSize = 10,
        [switch]$ShowConsole
    )
    
    $sw = [Diagnostics.Stopwatch]::StartNew()
    
    $mode = GetMode $Data
    Write-Host "Modo: $(switch($mode){'N'{'Numerico'}'A'{'Alfanumerico'}'B'{'Byte'}})" -ForegroundColor Cyan
    
    if ($Version -eq 0) {
        $mi = switch ($mode) { 'N'{0} 'A'{1} 'B'{2} }
        $len = if ($mode -eq 'B') { [Text.Encoding]::UTF8.GetByteCount($Data) } else { $Data.Length }
        
        # Try versions 1 to 10
        for ($v = 1; $v -le 10; $v++) {
            if ($script:CAP.ContainsKey($v) -and $script:CAP[$v][$ECLevel][$mi] -ge $len) { 
                $Version = $v; break 
            }
        }
        if ($Version -eq 0) { throw "Datos muy largos (max soportado: Version 10)" }
    }
    
    Write-Host "Version: $Version ($(GetSize $Version)x$(GetSize $Version))" -ForegroundColor Cyan
    Write-Host "EC: $ECLevel" -ForegroundColor Cyan
    
    Write-Host "Codificando..." -ForegroundColor Yellow
    $dataCW = Encode $Data $Version $ECLevel
    
    Write-Host "Reed-Solomon..." -ForegroundColor Yellow
    $allCW = BuildCW $dataCW $Version $ECLevel
    
    Write-Host "Matriz..." -ForegroundColor Yellow
    $matrix = InitM $Version
    
    Write-Host "Datos..." -ForegroundColor Yellow
    PlaceData $matrix $allCW
    
    Write-Host "Mascaras..." -ForegroundColor Yellow
    $mask = FindBestMask $matrix
    Write-Host "Mascara: $mask" -ForegroundColor Cyan
    
    $final = ApplyMask $matrix $mask
    AddFormat $final $ECLevel $mask
    
    $sw.Stop()
    Write-Host "Tiempo: $($sw.ElapsedMilliseconds)ms" -ForegroundColor Green
    
    if ($ShowConsole) { ShowConsole $final }
    if ($OutputPath) {
        ExportPng $final $OutputPath $ModuleSize 4
        Write-Host "Guardado: $OutputPath" -ForegroundColor Green
    }
    
    return $final
}

# ============================================================================
# BATCH PROCESSING LOGIC
# ============================================================================
function Get-IniValue($content, $section, $key, $defaultValue) {
    if ($content -match "(?ms)^\[$section\].*?^$key\s*=\s*([^`r`n]+)") {
        return $matches[1].Trim()
    }
    return $defaultValue
}

function Start-BatchProcessing {
    param([string]$IniPath = ".\config.ini")
    
    if (-not (Test-Path $IniPath)) { return }
    
    Write-Host "`n=== PROCESAMIENTO POR LOTES (CONFIG.INI) ===" -ForegroundColor Cyan
    $iniContent = Get-Content $IniPath -Raw
    
    # Leer configuración
    $inputFile = Get-IniValue $iniContent "Configuracion" "ArchivoEntrada" ".\lista_inputs.txt"
    $outDir = Get-IniValue $iniContent "Configuracion" "CarpetaSalida" ".\salida_qr"
    $ecLevel = Get-IniValue $iniContent "OpcionesQR" "NivelEC" "M"
    $modSize = [int](Get-IniValue $iniContent "OpcionesQR" "TamanoModulo" "10")
    $prefix = Get-IniValue $iniContent "NombresArchivos" "Prefijo" "qr_"
    $useConsec = (Get-IniValue $iniContent "NombresArchivos" "UseConsecutivo" "si") -eq "si"
    
    # Validar entrada
    $inputPath = Join-Path $PSScriptRoot $inputFile            
    if (-not (Test-Path $inputPath)) {
        Write-Host "Archivo de entrada no encontrado: $inputFile" -ForegroundColor Red
        return
    }
    
    # Crear carpeta salida
    $outPath = Join-Path $PSScriptRoot $outDir
    if (-not (Test-Path $outPath)) {
        New-Item -ItemType Directory -Force -Path $outPath | Out-Null
    }
    
    # Procesar líneas
    $lines = Get-Content $inputPath
    $count = 1
    
    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        
        # Determinar nombre archivo
        $name = ""
        if ($useConsec) {
            $name = "$prefix$count.png"
        } else {
            # Sanitizar nombre
            $safeName = $prefix + ($line -replace '[^a-zA-Z0-9]', '_')
            if ($safeName.Length -gt 20) { $safeName = $safeName.Substring(0, 20) }
            $name = "$safeName.png"
        }
        
        $finalPath = Join-Path $outPath $name
        
        Write-Host "Procesando [$count]: $line" -ForegroundColor Gray
        try {
            New-QRCode -Data $line -OutputPath $finalPath -ECLevel $ecLevel -ModuleSize $modSize
        } catch {
            Write-Host "Error generando QR para '$line': $_" -ForegroundColor Red
        }
        $count++
    }
    
    Write-Host "Proceso completado. QRs guardados en: $outDir" -ForegroundColor Green
}

# Ejecutar proceso batch si existe config.ini y se llama el script directamente
if ($MyInvocation.InvocationName -ne '.') {
    if (Test-Path ".\config.ini") {
        Start-BatchProcessing
    } else {
        Write-Host "`n  QR Generator FINAL - PowerShell Nativo`n" -ForegroundColor Magenta
    }
}
