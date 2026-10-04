@echo off
setlocal
set "GRADLE_VERSION=8.9"
set "VIA_GRADLE_HOME=%USERPROFILE%\.gradle\via-wrapper\gradle-%GRADLE_VERSION%"
set "GRADLE_EXE=%VIA_GRADLE_HOME%\bin\gradle.bat"

if not exist "%GRADLE_EXE%" (
  echo [VIA] Pinned Gradle %GRADLE_VERSION% was not found. Bootstrapping it into %VIA_GRADLE_HOME%...
  set "VIA_TMP=%TEMP%\via-gradle-%GRADLE_VERSION%.zip"
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://services.gradle.org/distributions/gradle-8.9-bin.zip' -OutFile $env:VIA_TMP; if (Test-Path $env:VIA_GRADLE_HOME) { Remove-Item -Recurse -Force $env:VIA_GRADLE_HOME }; $parent=Split-Path -Parent $env:VIA_GRADLE_HOME; New-Item -ItemType Directory -Force -Path $parent | Out-Null; Expand-Archive -Path $env:VIA_TMP -DestinationPath $parent -Force; Remove-Item -Force $env:VIA_TMP"
  if errorlevel 1 (
    echo [VIA] Unable to bootstrap Gradle %GRADLE_VERSION%. Check internet access and Java availability.
    exit /b 1
  )
)

call "%GRADLE_EXE%" %*
set "EXIT_CODE=%ERRORLEVEL%"
endlocal & exit /b %EXIT_CODE%
