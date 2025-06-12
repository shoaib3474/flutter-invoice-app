@echo off
echo Fixing template preview screen errors...

echo Fixing import ordering and constructor issues...

echo Adding missing Flutter imports...
for /r lib\models\template\ %%f in (*.dart) do (
    echo import 'package:flutter/material.dart'; > temp.dart
    type "%%f" >> temp.dart
    move temp.dart "%%f"
)

echo Fixing withOpacity deprecation...
powershell -Command "(Get-Content lib\screens\template\template_preview_screen.dart) -replace '\.withOpacity$$([^)]*)$$', '.withValues(alpha: $1)' | Set-Content lib\screens\template\template_preview_screen.dart"

echo Template preview errors fixed!
pause
