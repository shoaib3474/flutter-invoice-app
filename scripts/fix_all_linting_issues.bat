@echo off
echo 🔧 Fixing all linting issues in Flutter Invoice App...

REM 1. Clean and get dependencies
echo 📦 Cleaning and getting dependencies...
flutter clean
flutter pub get

REM 2. Fix double literals (Windows version)
echo 🔢 Fixing double literals...
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace '\.0\)', ')' | Set-Content $_.FullName }"
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace ': 0\.0', ': 0' | Set-Content $_.FullName }"
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace '= 0\.0', '= 0' | Set-Content $_.FullName }"

REM 3. Fix const constructors
echo 🏗️ Fixing const constructors...
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'Text\(', 'const Text(' | Set-Content $_.FullName }"
powershell -Command "(Get-ChildItem -Path lib -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'Icon\(', 'const Icon(' | Set-Content $_.FullName }"

REM 4. Remove unused imports and fix issues
echo 🧹 Removing unused imports...
dart fix --apply

REM 5. Format code
echo ✨ Formatting code...
dart format lib\ --fix

REM 6. Generate missing files
echo 🔨 Generating missing files...
flutter packages pub run build_runner build --delete-conflicting-outputs

echo ✅ All linting issues fixed!
pause
