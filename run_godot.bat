@echo off
REM Helper: run Godot 4.3 for the Aetherion project (game/ folder)
REM Usage:
REM   run_godot.bat              -> open editor
REM   run_godot.bat --headless --quit          -> import + quit (headless build check)
REM   run_godot.bat --headless --script res://tests/run_tests.gd  -> run test runner
set GODOT="D:\2DGAME\_tools\godot\Godot_v4.3-stable_win64.exe"
%GODOT% --path "D:\2DGAME\game" %*
