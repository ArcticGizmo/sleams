@echo off
setlocal

:: Read version from csproj if not passed as argument
if not "%~1"=="" (
    set VERSION=%~1
) else (
    for /f "tokens=*" %%i in ('powershell -NoProfile -Command "(Select-Xml -Path src\Otter.csproj -XPath \"//Version\").Node.InnerText"') do set VERSION=%%i
)

if "%VERSION%"=="" (
    echo Error: Could not determine version. Pass as argument: publish.bat 1.2.3
    exit /b 1
)

echo Building Otter v%VERSION%...

dotnet publish src\Otter.csproj -c Release -r win-x64 --self-contained true ^
    -p:DebugType=embedded ^
    -p:Version=%VERSION% ^
    -o publish\

if %ERRORLEVEL% neq 0 (
    echo Build failed.
    exit /b %ERRORLEVEL%
)

echo Packaging ...

dnx vpk pack --packId Otter --packTitle "Otter" --packVersion %VERSION% --packDir publish\ --mainExe Otter.exe --outputDir releases\

if %ERRORLEVEL% neq 0 (
    echo Pack failed. Is the vpk CLI installed? Run: dotnet tool install -g vpk
    exit /b %ERRORLEVEL%
)

echo Writing checksums ...

:: Mirrors the SHA256SUMS.txt that release.yml publishes, so install.ps1 can be pointed at a local pack and
:: a hand-uploaded release still ships checksums. Written LF-terminated with lower-case hex in sha256sum's
:: own format, so `sha256sum -c SHA256SUMS.txt` validates it as-is. Note this hashes EVERYTHING currently in
:: releases\ -- a local dir accumulates older versions' nupkgs, unlike CI's clean per-run artifact set.
:: The manifest itself is skipped with Where-Object, NOT -Exclude: Get-ChildItem silently IGNORES -Exclude
:: when it is paired with -LiteralPath, so re-running would otherwise hash the previous manifest into the
:: new one.
powershell -NoProfile -Command "$d = Resolve-Path 'releases'; $lines = Get-ChildItem -File -LiteralPath $d | Where-Object Name -ne 'SHA256SUMS.txt' | Sort-Object Name | ForEach-Object { '{0}  {1}' -f (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant(), $_.Name }; [System.IO.File]::WriteAllText((Join-Path $d 'SHA256SUMS.txt'), ($lines -join [char]10) + [char]10); Write-Host ('  ' + @($lines).Count + ' files hashed')"

if %ERRORLEVEL% neq 0 (
    echo Checksum generation failed.
    exit /b %ERRORLEVEL%
)

echo.
echo Release artifacts ready in: releases\
echo Upload to: https://github.com/ArcticGizmo/otter/releases/new?tag=v%VERSION%
echo   Include SHA256SUMS.txt -- install.ps1 refuses to install a release without it.
