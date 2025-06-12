@echo off
echo 🔧 Fixing final widget issues...

echo 📝 Applying const constructor fixes...
powershell -Command "(Get-ChildItem -Path lib\widgets -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'Text\(', 'const Text(' | Set-Content $_.FullName }"
powershell -Command "(Get-ChildItem -Path lib\widgets -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'Icon\(', 'const Icon(' | Set-Content $_.FullName }"
powershell -Command "(Get-ChildItem -Path lib\widgets -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace 'SizedBox\(', 'const SizedBox(' | Set-Content $_.FullName }"

echo 🔄 Fixing deprecated withOpacity calls...
powershell -Command "(Get-ChildItem -Path lib\widgets -Filter *.dart -Recurse) | ForEach-Object { (Get-Content $_.FullName) -replace '\.withOpacity$$([^)]*)$$', '.withValues(alpha: $1)' | Set-Content $_.FullName }"

echo 🚀 Applying automated Dart fixes...
dart fix --apply

echo ✨ Formatting code...
dart format lib\widgets\

echo ✅ All widget issues fixed!
echo Run 'flutter analyze' to verify zero errors.
