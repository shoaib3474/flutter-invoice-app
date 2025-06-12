@echo off
echo 🔧 Fixing RCM Widget Errors...

echo 📝 Fixing import paths...
powershell -Command "(Get-ChildItem -Path lib\widgets -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'package:invoice_app/', '../' | Set-Content $_.FullName }"

echo 🎯 Adding const constructors...
powershell -Command "(Get-ChildItem -Path lib\widgets -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'SizedBox(width: 8)', 'const SizedBox(width: 8)' | Set-Content $_.FullName }"
powershell -Command "(Get-ChildItem -Path lib\widgets -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'Text\(', 'const Text(' | Set-Content $_.FullName }"
powershell -Command "(Get-ChildItem -Path lib\widgets -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'Icon\(Icons\.', 'const Icon(Icons.' | Set-Content $_.FullName }"

echo ⚡ Fixing super parameters...
powershell -Command "(Get-ChildItem -Path lib\widgets -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'Key\? key', 'super.key' | Set-Content $_.FullName }"

echo 🔢 Fixing double literals...
powershell -Command "(Get-ChildItem -Path lib\widgets -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace '\.0\)', ')' | Set-Content $_.FullName }"

echo ✅ RCM Widget fixes completed!
echo 🚀 Run 'flutter analyze' to verify fixes
