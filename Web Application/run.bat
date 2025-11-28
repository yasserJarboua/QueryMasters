@echo off
echo.
echo ========================================================
echo    MNHS Hospital Management System - Starting...
echo ========================================================
echo.

:: Check if virtual environment exists
if not exist "venv" (
    echo Error: Virtual environment not found!
    echo Please run setup.bat first
    pause
    exit /b 1
)

:: Check if .env exists
if not exist ".env" (
    echo Error: .env file not found!
    echo Please create and configure your .env file
    pause
    exit /b 1
)

:: Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

:: Check if main.py exists
if not exist "main.py" (
    echo Error: main.py not found!
    pause
    exit /b 1
)

:: Start the application
echo Starting Flask application...
echo Press Ctrl+C to stop the server
echo.

python main.py
pause