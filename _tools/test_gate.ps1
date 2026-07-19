<#
.SYNOPSIS
  Test untuk GERBANGNYA SENDIRI (#273).

.DESCRIPTION
  Gerbang yang salah baca lebih berbahaya daripada tak ada gerbang — ia memberi
  keyakinan palsu. Jadi pembacaannya diuji, bukan dipercaya.

  Tiga kasus, dan yang KEDUA adalah alasan #273 ada:
    1. log sehat, 0 gagal          -> LULUS  (exit 0)
    2. log TERPENGGAL (crash)      -> GAGAL  (exit 2)   <- lubang lolos-palsu #249
    3. log sehat, ada [FAIL]       -> GAGAL  (exit 1)

  Kasus 2 memakai log yang dipenggal PERSIS seperti crash sungguhan: berhenti di
  tengah, nol baris [FAIL], nol baris RESULT. Pembacaan lama ("nol [FAIL] = lulus")
  akan MELOLOSKANNYA.
#>
$ErrorActionPreference = "Stop"
$here = $PSScriptRoot
$runner = Join-Path $here "run_suite.ps1"
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) "aether_gate_test"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

$pass = 0; $fail = 0
function Check {
    param([string]$Name, [bool]$Ok, [string]$Detail = "")
    if ($Ok) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor DarkGray }
    else     { $script:fail++; Write-Host "  [FAIL] $Name  $Detail" -ForegroundColor Red }
}

Write-Host "[#273: gerbang membaca RESULT, bukan sekadar ketiadaan FAIL]"

# --- kasus 1: sehat ---
$o1 = Join-Path $tmp "sehat.log"
@(
 "  [PASS] sesuatu"
 "  [PASS] sesuatu lagi"
 "===== RESULT: 1071 passed, 0 failed ====="
) | Set-Content -Path $o1 -Encoding utf8
$e1 = Join-Path $tmp "sehat.err"; "" | Set-Content -Path $e1 -Encoding utf8
& $runner -ParseOnly -OutLog $o1 -ErrLog $e1 -Quiet
Check "log sehat 0 gagal -> LULUS (exit 0)" ($LASTEXITCODE -eq 0) "exit=$LASTEXITCODE"

# --- kasus 2: TERPENGGAL — inilah lubangnya ---
$o2 = Join-Path $tmp "terpenggal.log"
@(
 "  [PASS] boss flagged"
 "  [PASS] boss starts phase 1"
) | Set-Content -Path $o2 -Encoding utf8
$e2 = Join-Path $tmp "terpenggal.err"
@(
 "CrashHandlerException: Program crashed with signal 11"
) | Set-Content -Path $e2 -Encoding utf8
& $runner -ParseOnly -OutLog $o2 -ErrLog $e2 -Quiet
Check "log TERPENGGAL (crash) -> GAGAL (exit 2), BUKAN lolos" ($LASTEXITCODE -eq 2) "exit=$LASTEXITCODE"
$adaFail = [bool]((Get-Content $o2) | Select-String -Pattern '\[FAIL\]' -Quiet)
Check "log terpenggal memang NOL [FAIL] (jadi pembacaan lama akan meloloskannya)" (-not $adaFail)

# --- kasus 3: kegagalan nyata ---
$o3 = Join-Path $tmp "gagal.log"
@(
 "  [PASS] sesuatu"
 "  [FAIL] sesuatu rusak  detail"
 "===== RESULT: 1070 passed, 1 failed ====="
) | Set-Content -Path $o3 -Encoding utf8
$e3 = Join-Path $tmp "gagal.err"; "" | Set-Content -Path $e3 -Encoding utf8
& $runner -ParseOnly -OutLog $o3 -ErrLog $e3 -Quiet
Check "log sehat dengan 1 gagal -> GAGAL (exit 1)" ($LASTEXITCODE -eq 1) "exit=$LASTEXITCODE"

# --- kasus 4: log kosong (godot tak pernah jalan) ---
$o4 = Join-Path $tmp "kosong.log"; "" | Set-Content -Path $o4 -Encoding utf8
& $runner -ParseOnly -OutLog $o4 -ErrLog $e1 -Quiet
Check "log kosong -> GAGAL (exit 2)" ($LASTEXITCODE -eq 2) "exit=$LASTEXITCODE"

Write-Host ""
Write-Host "===== GATE TEST: $pass lulus, $fail gagal ====="
exit $(if ($fail -gt 0) { 1 } else { 0 })
