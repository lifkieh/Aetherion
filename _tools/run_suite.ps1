<#
.SYNOPSIS
  Gerbang test Aetherion — #249 diperketat oleh #273.

.DESCRIPTION
  #249 menetapkan gerbang = "0 gagal, bukan jumlah lulus". Rumusan itu punya lubang
  yang ditemukan UTANG-249: suite bisa MATI DI TENGAH (segfault, signal 11) dan
  tidak pernah mencetak satu pun [FAIL] — sehingga pembacaan "nol [FAIL]" MELOLOSKANNYA.

  #273 menutupnya: suite lulus HANYA bila baris

      ===== RESULT: N passed, M failed =====

  HADIR dan M = 0. Nol baris RESULT = GAGAL, apa pun sebabnya.

  Kode keluar:
    0  LULUS   — baris RESULT ada, M = 0
    1  GAGAL   — baris RESULT ada, M > 0        (kegagalan nyata; selidiki commit)
    2  GAGAL   — baris RESULT TIDAK ADA         (mati di tengah; lihat UTANG-249)

.PARAMETER ParseOnly
  Jangan jalankan suite; baca log yang sudah ada. Dipakai test gerbang sendiri
  (`_tools/test_gate.ps1`) untuk membuktikan log terpenggal dibaca GAGAL.

.EXAMPLE
  pwsh _tools/run_suite.ps1
  pwsh _tools/run_suite.ps1 -Repeat 50          # ukur flakiness (UTANG-249)
  pwsh _tools/run_suite.ps1 -ParseOnly -OutLog a.log -ErrLog a.err
#>
param(
    [int]$Repeat = 1,
    [switch]$ParseOnly,
    [string]$OutLog = "",
    [string]$ErrLog = "",
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $PSScriptRoot
$godot = Join-Path $repo "_tools\godot\Godot_v4.3-stable_win64_console.exe"

function Read-Verdict {
    param([string]$StdoutPath, [string]$StderrPath)

    $out = if (Test-Path $StdoutPath) { Get-Content $StdoutPath } else { @() }
    $err = if ($StderrPath -and (Test-Path $StderrPath)) { Get-Content $StderrPath } else { @() }

    # #273 — baris RESULT adalah SATU-SATUNYA bukti suite selesai.
    $result = $out | Select-String -Pattern '=====\s*RESULT:\s*(\d+)\s*passed,\s*(\d+)\s*failed' |
              Select-Object -Last 1
    $crashed = [bool]($err | Select-String -Pattern 'signal 11|CrashHandlerException' -Quiet)
    $fails   = @($out | Select-String -Pattern '^\s*\[FAIL\]')

    if ($null -eq $result) {
        return [pscustomobject]@{
            Verdict = "GAGAL"; Code = 2; Passed = $null; Failed = $null
            Crashed = $crashed; Fails = $fails
            Why = if ($crashed) {
                      "suite MATI DI TENGAH (signal 11) — baris RESULT tak pernah dicetak. Ini UTANG-249, BUKAN regresi commit."
                  } else {
                      "baris RESULT tak ada — suite tidak selesai. Sebab belum diketahui; periksa stderr."
                  }
        }
    }
    $p = [int]$result.Matches[0].Groups[1].Value
    $m = [int]$result.Matches[0].Groups[2].Value
    if ($m -gt 0) {
        return [pscustomobject]@{
            Verdict = "GAGAL"; Code = 1; Passed = $p; Failed = $m
            Crashed = $crashed; Fails = $fails
            Why = "$m test gagal. Suite SELESAI, jadi ini kegagalan NYATA — selidiki commit."
        }
    }
    return [pscustomobject]@{
        Verdict = "LULUS"; Code = 0; Passed = $p; Failed = 0
        Crashed = $crashed; Fails = @()
        Why = "baris RESULT hadir dan 0 gagal (#249 + #273)."
    }
}

function Show-Verdict {
    param($v, [string]$Tag = "")
    $colour = if ($v.Verdict -eq "LULUS") { "Green" } else { "Red" }
    Write-Host ""
    Write-Host ("{0}{1} — {2}" -f $Tag, $v.Verdict, $v.Why) -ForegroundColor $colour
    if ($null -ne $v.Passed) { Write-Host ("  lulus={0} gagal={1}" -f $v.Passed, $v.Failed) }
    if ($v.Crashed) { Write-Host "  ⚠ crash terdeteksi di stderr (signal 11) — UTANG-249" -ForegroundColor Yellow }
    foreach ($f in $v.Fails) { Write-Host ("  " + $f.Line.Trim()) -ForegroundColor Red }
}

if ($ParseOnly) {
    $v = Read-Verdict -StdoutPath $OutLog -StderrPath $ErrLog
    if (-not $Quiet) { Show-Verdict $v }
    exit $v.Code
}

$tmp = [System.IO.Path]::GetTempPath()
$tally = [ordered]@{ LULUS = 0; "GAGAL-nyata" = 0; "GAGAL-mati" = 0 }
$worst = 0

for ($i = 1; $i -le $Repeat; $i++) {
    $lo = Join-Path $tmp ("aether_suite_{0}.log" -f $i)
    $le = Join-Path $tmp ("aether_suite_{0}.err" -f $i)
    Start-Process -FilePath $godot `
        -ArgumentList "--path", (Join-Path $repo "game"), "--headless", "res://tests/TestRunner.tscn" `
        -NoNewWindow -Wait -RedirectStandardOutput $lo -RedirectStandardError $le | Out-Null

    $v = Read-Verdict -StdoutPath $lo -StderrPath $le
    switch ($v.Code) {
        0 { $tally.LULUS++ }
        1 { $tally."GAGAL-nyata"++ }
        2 { $tally."GAGAL-mati"++ }
    }
    if ($v.Code -gt $worst) { $worst = $v.Code }

    if ($Repeat -eq 1) {
        Show-Verdict $v
        Write-Host "  stdout: $lo"
        Write-Host "  stderr: $le"
    } elseif (-not $Quiet) {
        Write-Host ("run {0,3}/{1}  {2}" -f $i, $Repeat, $v.Verdict) -ForegroundColor `
            $(if ($v.Verdict -eq "LULUS") { "DarkGray" } else { "Red" })
        if ($v.Code -ne 0) { Write-Host ("        -> " + $v.Why) -ForegroundColor Yellow }
    }
}

if ($Repeat -gt 1) {
    Write-Host ""
    Write-Host "===== $Repeat RUN ====="
    foreach ($k in $tally.Keys) { Write-Host ("  {0,-12} {1}" -f $k, $tally[$k]) }
    $rate = [math]::Round(100.0 * $tally."GAGAL-mati" / $Repeat, 1)
    Write-Host ("  laju mati-di-tengah: {0}%  (UTANG-249)" -f $rate)
}

exit $worst
