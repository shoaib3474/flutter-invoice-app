@echo off
echo 🔧 Fixing remaining linting issues...

echo 📝 Fixing super parameters...
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'const ([A-Za-z_][A-Za-z0-9_]*)\(\{Key\? key', 'const $1({super.key' | Set-Content $_.FullName }"
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace '([A-Za-z_][A-Za-z0-9_]*)\(\{Key\? key', '$1({super.key' | Set-Content $_.FullName }"

echo 📝 Fixing double literals...
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace '\.0\)', ')' | Set-Content $_.FullName }"
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace '\.0,', ',' | Set-Content $_.FullName }"

echo 📝 Fixing deprecated withOpacity...
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace '\.withOpacity$$([^)]*)$$', '.withValues(alpha: $1)' | Set-Content $_.FullName }"

echo ✅ Basic linting fixes applied!
