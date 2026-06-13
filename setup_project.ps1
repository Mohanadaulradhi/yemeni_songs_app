param(
    [string]$FlutterPath = "flutter"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TempProject = Join-Path $env:TEMP "yemeni_songs_temp_$(Get-Random)"

Write-Host "=== تجهيز مشروع تطبيق الأغاني اليمنية ===" -ForegroundColor Cyan

# 1. التحقق من وجود Flutter
Write-Host "[1/4] التحقق من Flutter SDK..." -ForegroundColor Yellow
try {
    $flutterVersion = & $FlutterPath --version 2>&1 | Select-String -Pattern "^Flutter" | ForEach-Object { $_.ToString() }
    if (-not $flutterVersion) { throw "Flutter not found" }
    Write-Host "  ✓ $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Flutter SDK غير موجود! الرجاء تثبيت Flutter أولاً:" -ForegroundColor Red
    Write-Host "    https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
    exit 1
}

# 2. إنشاء مشروع Flutter مؤقت للحصول على الملفات الثنائية
Write-Host "[2/4] إنشاء مشروع مؤقت لاستخراج ملفات البناء..." -ForegroundColor Yellow
try {
    & $FlutterPath create --project-name temp_app --platforms android,ios $TempProject 2>&1 | Out-Null
    Write-Host "  ✓ تم إنشاء المشروع المؤقت" -ForegroundColor Green
} catch {
    Write-Host "  ✗ فشل في إنشاء المشروع المؤقت: $_" -ForegroundColor Red
    exit 1
}

# 3. نسخ الملفات المفقودة
Write-Host "[3/4] نسخ ملفات Gradle و Xcode..." -ForegroundColor Yellow

# Android - ملفات Gradle الثنائية
$androidTarget = Join-Path $ProjectRoot "android"

if (-not (Test-Path (Join-Path $androidTarget "gradlew"))) {
    Copy-Item (Join-Path $TempProject "android\gradlew") $androidTarget -Force
    Write-Host "  ✓ gradlew"
}
if (-not (Test-Path (Join-Path $androidTarget "gradlew.bat"))) {
    Copy-Item (Join-Path $TempProject "android\gradlew.bat") $androidTarget -Force
    Write-Host "  ✓ gradlew.bat"
}
$wrapperDir = Join-Path $androidTarget "gradle\wrapper"
if (-not (Test-Path $wrapperDir)) { New-Item -ItemType Directory -Path $wrapperDir -Force | Out-Null }
if (-not (Test-Path (Join-Path $wrapperDir "gradle-wrapper.jar"))) {
    Copy-Item (Join-Path $TempProject "android\gradle\wrapper\gradle-wrapper.jar") $wrapperDir -Force
    Write-Host "  ✓ gradle-wrapper.jar"
}

# iOS - Xcode project
$iosTarget = Join-Path $ProjectRoot "ios"
$tempXcproj = Join-Path $TempProject "ios\Runner.xcodeproj"
$targetXcproj = Join-Path $iosTarget "Runner.xcodeproj"
if (-not (Test-Path $targetXcproj)) {
    Copy-Item $tempXcproj $targetXcproj -Recurse -Force
    Write-Host "  ✓ Runner.xcodeproj"
}

# iOS - Flutter directory (Generated.xcconfig, etc.)
$tempFlutterDir = Join-Path $TempProject "ios\Flutter"
$targetFlutterDir = Join-Path $iosTarget "Flutter"
if (-not (Test-Path $targetFlutterDir)) {
    Copy-Item $tempFlutterDir $targetFlutterDir -Recurse -Force
    Write-Host "  ✓ ios/Flutter/"
}

# 4. تنظيف المشروع المؤقت
Remove-Item $TempProject -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "  ✓ تم حذف المشروع المؤقت" -ForegroundColor Green

# 5. تحديث local.properties
Write-Host "[4/4] إعداد local.properties..." -ForegroundColor Yellow
$localProps = Join-Path $androidTarget "local.properties"
$flutterSdkPath = & $FlutterPath --version 2>&1 | Select-String "• Flutter" | ForEach-Object { $_ -replace '.* at ','' } | ForEach-Object { $_.Trim() }
$androidSdkPath = $env:ANDROID_HOME
if (-not $androidSdkPath) { $androidSdkPath = "$env:LOCALAPPDATA\Android\Sdk" }

@"
sdk.dir=$($androidSdkPath -replace '\\','\\')
flutter.sdk=$($flutterSdkPath -replace '\\','\\')
flutter.buildMode=debug
flutter.versionName=1.0.0
flutter.versionCode=1
"@ | Set-Content $localProps -Encoding ASCII
Write-Host "  ✓ local.properties (Flutter: $flutterSdkPath)" -ForegroundColor Green

# 6. تثبيت التبعيات
Write-Host "=== تثبيت التبعيات ===" -ForegroundColor Cyan
try {
    Push-Location $ProjectRoot
    & $FlutterPath pub get 2>&1 | Out-Null
    Write-Host "  ✓ flutter pub get نجح" -ForegroundColor Green
} catch {
    Write-Host "  ✗ flutter pub get فشل: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "=== ✅ تم التجهيز بنجاح! ===" -ForegroundColor Green
Write-Host "لتشغيل التطبيق:" -ForegroundColor White
Write-Host "  cd `"$ProjectRoot`"" -ForegroundColor Cyan
Write-Host "  flutter run" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  لا تنس تحديث ملف .env ببيانات Appwrite الحقيقية!" -ForegroundColor Yellow
