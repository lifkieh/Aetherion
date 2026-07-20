@echo off
REM Helper: run Godot 4.3 for the Aetherion project (game/ folder)
REM Usage:
REM   run_godot.bat              -> open editor
REM   run_godot.bat --headless --quit          -> import + quit (headless build check)
REM   run_godot.bat --headless res://tests/TestRunner.tscn        -> run test runner
REM   (dulu tertulis --script res://tests/run_tests.gd — berkas itu TIDAK ADA)
REM   run_godot.bat --headless --import                          -> import aset baru
REM     ^ WAJIB setelah menambah PNG di luar editor: tanpa ini ResourceLoader.exists()
REM       mengembalikan false dan scene diam-diam jatuh ke placeholder.
set GODOT="D:\2DGAME\_tools\godot\Godot_v4.3-stable_win64.exe"
%GODOT% --path "D:\2DGAME\game" %*
