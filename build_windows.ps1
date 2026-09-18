[CmdletBinding()]
param(
    [switch]$SkipInstall
)

$ErrorActionPreference = "Stop"
$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuildVenv = Join-Path $ProjectDir ".venv-win-build"
$DistDir = Join-Path $ProjectDir "dist"
$AppDir = Join-Path $DistDir "LiteratureManager"
$ZipPath = Join-Path $DistDir "LiteratureManager-Windows-x64.zip"

Set-Location $ProjectDir

function Assert-NativeSuccess {
    param([string]$Operation)
    if ($LASTEXITCODE -ne 0) {
        throw "$Operation 失败，退出码：$LASTEXITCODE"
    }
}

if ($SkipInstall) {
    $PythonExe = (Get-Command python -ErrorAction Stop).Source
} else {
    $PythonExe = Join-Path $BuildVenv "Scripts\python.exe"
    if (-not (Test-Path -LiteralPath $PythonExe)) {
        $Launcher = Get-Command py -ErrorAction SilentlyContinue
        if ($Launcher) {
            & $Launcher.Source -3 -c "import sys; raise SystemExit(sys.version_info < (3, 10))"
            if ($LASTEXITCODE -ne 0) { throw "构建需要 Python 3.10 或更高版本。" }
            & $Launcher.Source -3 -m venv $BuildVenv
            Assert-NativeSuccess "创建构建虚拟环境"
        } else {
            $Python = Get-Command python -ErrorAction Stop
            & $Python.Source -c "import sys; raise SystemExit(sys.version_info < (3, 10))"
            if ($LASTEXITCODE -ne 0) { throw "构建需要 Python 3.10 或更高版本。" }
            & $Python.Source -m venv $BuildVenv
            Assert-NativeSuccess "创建构建虚拟环境"
        }
    }
    & $PythonExe -m pip install --upgrade pip
    Assert-NativeSuccess "升级 pip"
    & $PythonExe -m pip install -r requirements-windows.txt
    Assert-NativeSuccess "安装构建依赖"
}

& $PythonExe -c "import sys; raise SystemExit(sys.version_info < (3, 10))"
Assert-NativeSuccess "Python 版本检查"
& $PythonExe -m PyInstaller `
    --noconfirm `
    --clean `
    --windowed `
    --onedir `
    --name LiteratureManager `
    --add-data "README.md;." `
    run_literature_manager.py
Assert-NativeSuccess "PyInstaller 构建"

if (-not (Test-Path -LiteralPath (Join-Path $AppDir "LiteratureManager.exe"))) {
    throw "Windows 可执行文件构建失败。"
}

$ReleaseFiles = @(
    "README.md",
    "LICENSE",
    "THIRD_PARTY_NOTICES.md",
    "SOURCE_CODE.txt"
)
foreach ($ReleaseFile in $ReleaseFiles) {
    Copy-Item -LiteralPath (Join-Path $ProjectDir $ReleaseFile) -Destination $AppDir -Force
}
Copy-Item -LiteralPath (Join-Path $ProjectDir "licenses") -Destination $AppDir -Recurse -Force

if (Test-Path -LiteralPath $ZipPath) {
    Remove-Item -LiteralPath $ZipPath -Force
}
Compress-Archive -Path $AppDir -DestinationPath $ZipPath -CompressionLevel Optimal

Write-Host "构建完成：$AppDir"
Write-Host "发布压缩包：$ZipPath"
