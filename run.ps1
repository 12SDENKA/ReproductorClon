Write-Host "===================================" -ForegroundColor Cyan
Write-Host " ReproductorClon - Flutter App" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

$env:Path = "C:\flutter\bin;" + [System.Environment]::GetEnvironmentVariable("Path","Machine")

flutter --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter not found at C:\flutter\bin" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "Available options:" -ForegroundColor Yellow
Write-Host "  1. Run in Chrome (web)"
Write-Host "  2. Build for web (release)"
Write-Host "  3. Build APK for Android"
Write-Host "  4. Analyze code"
Write-Host "  5. Run tests"
Write-Host ""
$choice = Read-Host "Select option (1-5)"

switch ($choice) {
    "1" { flutter run -d chrome }
    "2" {
        flutter build web --release
        Write-Host ""
        Write-Host "Build complete!" -ForegroundColor Green
        Write-Host "Open: C:\Users\xeno\ReproductorClon\build\web\index.html"
        Start-Process "C:\Users\xeno\ReproductorClon\build\web\index.html"
    }
    "3" { flutter build apk --release }
    "4" { flutter analyze }
    "5" { flutter test }
}

pause
