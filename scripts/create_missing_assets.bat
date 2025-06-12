@echo off

echo 📁 Creating missing asset directories and files...

REM Create asset directories
mkdir assets\images 2>nul
mkdir assets\icons 2>nul
mkdir assets\fonts 2>nul
mkdir assets\templates 2>nul
mkdir assets\config 2>nul

REM Create placeholder files
echo. > assets\icons\app_icon.png
echo. > assets\fonts\Roboto-Regular.ttf
echo. > assets\fonts\Roboto-Bold.ttf
echo. > assets\fonts\OpenSans-Regular.ttf
echo. > assets\fonts\OpenSans-Bold.ttf
echo. > assets\images\logo.png
echo. > assets\images\splash_background.png

REM Create config file
(
echo {
echo   "app_name": "GST Invoice App",
echo   "version": "1.0.0",
echo   "api_base_url": "https://api.gstinvoice.com",
echo   "features": {
echo     "offline_mode": true,
echo     "cloud_sync": true,
echo     "pdf_generation": true
echo   }
echo }
) > assets\config\app_config.json

echo ✅ Asset directories and placeholder files created!
