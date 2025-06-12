@echo off
echo 🔧 Fixing Critical Flutter Errors...

echo 📝 Fixing super parameters...
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'Key\? key', 'super.key' | Set-Content $_.FullName }"

echo 📝 Fixing double literals...
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace '\.0\)', ')' | Set-Content $_.FullName }"

echo 📝 Fixing deprecated withOpacity...
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace '\.withOpacity$$([^)]*)$$', '.withValues(alpha: $1)' | Set-Content $_.FullName }"

echo 📝 Replacing print with debugPrint...
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'print\(', 'debugPrint(' | Set-Content $_.FullName }"

echo ✅ Critical errors fixed!
echo 🔍 Run 'flutter analyze' to check remaining issues
