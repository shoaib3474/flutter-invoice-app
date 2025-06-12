@echo off
echo 🔧 Fixing deprecated APIs and syntax errors...

REM Fix deprecated APIs in Dart files using PowerShell
powershell -Command "Get-ChildItem -Path lib -Filter *.dart -Recurse | ForEach-Object { (Get-Content $_.FullName) -replace 'FlatButton', 'TextButton' -replace 'RaisedButton', 'ElevatedButton' -replace 'OutlineButton', 'OutlinedButton' -replace 'Scaffold\.of$$context$$\.showSnackBar', 'ScaffoldMessenger.of(context).showSnackBar' -replace 'Theme\.of$$context$$\.accentColor', 'Theme.of(context).colorScheme.secondary' -replace 'TextTheme$$$$\.headline6', 'TextTheme().titleLarge' -replace 'TextTheme$$$$\.headline5', 'TextTheme().headlineSmall' -replace 'TextTheme$$$$\.subtitle1', 'TextTheme().titleMedium' -replace 'TextTheme$$$$\.bodyText1', 'TextTheme().bodyLarge' -replace 'TextTheme$$$$\.bodyText2', 'TextTheme().bodyMedium' -replace 'autovalidate:', 'autovalidateMode: AutovalidateMode.onUserInteraction,' | Set-Content $_.FullName }"

echo ✅ Deprecated APIs fixed!
