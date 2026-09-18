@echo off
setlocal
cd /d "%~dp0"

set "PACKAGED_EXE=dist\LiteratureManager\LiteratureManager.exe"
if exist "%PACKAGED_EXE%" (
    start "Literature Manager" "%PACKAGED_EXE%"
    exit /b 0
)

set "VENV_PY=.venv\Scripts\python.exe"
set "VENV_PYW=.venv\Scripts\pythonw.exe"

if exist "%VENV_PY%" (
    "%VENV_PY%" -c "import sys; raise SystemExit(sys.version_info < (3, 10))"
    if errorlevel 1 goto venv_too_old
    goto check_dependencies
)

where py >nul 2>nul
if not errorlevel 1 (
    py -3 -c "import sys; raise SystemExit(sys.version_info < (3, 10))"
    if errorlevel 1 goto python_version
    py -3 -m venv .venv
) else (
    where python >nul 2>nul
    if errorlevel 1 goto python_missing
    python -c "import sys; raise SystemExit(sys.version_info < (3, 10))"
    if errorlevel 1 goto python_version
    python -m venv .venv
)
if errorlevel 1 goto setup_failed

:check_dependencies
"%VENV_PY%" -c "import PySide6, fitz" >nul 2>nul
if not errorlevel 1 goto launch

echo Installing dependencies for the first run...
"%VENV_PY%" -m pip install --upgrade pip
if errorlevel 1 goto setup_failed
"%VENV_PY%" -m pip install -r requirements.txt
if errorlevel 1 goto setup_failed

:launch
start "Literature Manager" "%VENV_PYW%" "%~dp0run_literature_manager.py"
exit /b 0

:python_missing
echo.
echo Python 3 was not found. Install Python 3.10 or newer from:
echo https://www.python.org/downloads/windows/
echo Select "Add python.exe to PATH" during installation, then try again.
goto wait_on_error

:python_version
echo.
echo Python 3.10 or newer is required.
echo Install it from https://www.python.org/downloads/windows/ and try again.
goto wait_on_error

:venv_too_old
echo.
echo The existing .venv uses an unsupported Python version.
echo Delete the .venv folder and run this launcher again.
goto wait_on_error

:setup_failed
echo.
echo Setup failed. Review the error messages above and check your network connection.

:wait_on_error
echo.
pause
exit /b 1
