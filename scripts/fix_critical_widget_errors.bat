@echo off
echo 🔧 Fixing critical widget errors...

echo 📝 Fixing constructor ordering...
for /r lib\widgets %%f in (*.dart) do (
    powershell -Command "(Get-Content '%%f') -replace 'const ([A-Z][a-zA-Z]*)\(\{', 'const $1({' | Set-Content '%%f'"
)

echo 🔄 Fixing deprecated withOpacity usage...
for /r lib %%f in (*.dart) do (
    powershell -Command "(Get-Content '%%f') -replace '\.withOpacity$$([^)]*)$$', '.withValues(alpha: $1)' | Set-Content '%%f'"
)

echo 🖨️ Replacing print statements...
for /r lib %%f in (*.dart) do (
    powershell -Command "(Get-Content '%%f') -replace 'print\(', 'debugPrint(' | Set-Content '%%f'"
)

echo ⚡ Adding const constructors...
for /r lib\widgets %%f in (*.dart) do (
    powershell -Command "(Get-Content '%%f') -replace 'SizedBox$$height: ([0-9.]*)$$', 'const SizedBox(height: $1)' | Set-Content '%%f'"
    powershell -Command "(Get-Content '%%f') -replace 'SizedBox$$width: ([0-9.]*)$$', 'const SizedBox(width: $1)' | Set-Content '%%f'"
)

echo ✅ Critical widget errors fixed!
pause
