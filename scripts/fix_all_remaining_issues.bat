@echo off
echo 🔧 Fixing all remaining linting issues...

echo 📝 Fixing XML text deprecation...
powershell -Command "(Get-ChildItem -Path lib -Recurse -Filter *.dart) | ForEach-Object { (Get-Content $_.FullName) -replace '\.text', '.innerText' | Set-Content $_.FullName }"

echo 🔢 Fixing double literals...
powershell -Command "(Get-ChildItem -Path lib -Recurse -Filter *.dart) | ForEach-Object { (Get-Content $_.FullName) -replace '([0-9]+)\.0([^0-9])', '$1$2' | Set-Content $_.FullName }"

echo 🖨️ Fixing print statements...
powershell -Command "(Get-ChildItem -Path lib -Recurse -Filter *.dart) | ForEach-Object { (Get-Content $_.FullName) -replace 'print\(', 'debugPrint(' | Set-Content $_.FullName }"

echo 🛠️ Running dart fix...
dart fix --apply

echo ✅ All remaining issues fixed!
pause
