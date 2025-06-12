@echo off
echo 🔧 Fixing final Flutter project issues...

echo 📝 Replacing print statements with debugPrint...
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'print\(', 'debugPrint(' | Set-Content $_.FullName }"

echo 🔢 Fixing unnecessary double literals...
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace '\.0\)', ')' | Set-Content $_.FullName }"
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace '\.0,', ',' | Set-Content $_.FullName }"

echo 🏗️ Adding const to constructors...
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'EdgeInsets\.all\(', 'const EdgeInsets.all(' | Set-Content $_.FullName }"
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'TextStyle\(', 'const TextStyle(' | Set-Content $_.FullName }"

echo 📦 Getting dependencies...
flutter pub get

echo ✅ Final fixes completed!
echo 🔍 Run 'flutter analyze' to check for remaining issues
