@echo off
setlocal EnableDelayedExpansion

:: Colors using PowerShell
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "BLUE=[94m"
set "NC=[0m"

echo.
echo ========================================================
echo    MNHS Hospital Management System - Setup Script
echo ========================================================
echo.

:: Check if Python is installed
echo [1/6] Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo %RED%Error: Python is not installed or not in PATH%NC%
    echo Please install Python 3.8 or higher from https://www.python.org/
    pause
    exit /b 1
)
python --version
echo %GREEN%Python found%NC%

:: Check if pip is installed
echo.
echo [2/6] Checking pip installation...
pip --version >nul 2>&1
if errorlevel 1 (
    echo %RED%Error: pip is not installed%NC%
    pause
    exit /b 1
)
echo %GREEN%pip found%NC%

:: Check if virtual environment exists
echo.
echo [3/6] Checking virtual environment...
if exist "venv" (
    echo %GREEN%Virtual environment already exists%NC%
    set /p "recreate=Do you want to recreate it? (y/N): "
    if /i "!recreate!"=="y" (
        echo Removing existing virtual environment...
        rmdir /s /q venv
        echo Creating new virtual environment...
        python -m venv venv
        echo %GREEN%Virtual environment created%NC%
    )
) else (
    echo Creating virtual environment...
    python -m venv venv
    if errorlevel 1 (
        echo %RED%Error: Failed to create virtual environment%NC%
        pause
        exit /b 1
    )
    echo %GREEN%Virtual environment created%NC%
)

:: Activate virtual environment
echo.
echo [4/6] Activating virtual environment...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo %RED%Error: Failed to activate virtual environment%NC%
    pause
    exit /b 1
)
echo %GREEN%Virtual environment activated%NC%

:: Install dependencies
echo.
echo [5/6] Installing dependencies...
if exist "requirements.txt" (
    python -m pip install --upgrade pip
    pip install -r requirements.txt
    if errorlevel 1 (
        echo %RED%Error: Failed to install dependencies%NC%
        pause
        exit /b 1
    )
    echo %GREEN%Dependencies installed successfully%NC%
) else (
    echo %YELLOW%requirements.txt not found!%NC%
    echo Creating requirements.txt with basic dependencies...
    (
        echo Flask==3.0.0
        echo Flask-SQLAlchemy==3.1.1
        echo python-dotenv==1.0.0
        echo PyMySQL==1.1.0
        echo cryptography==41.0.7
    ) > requirements.txt
    pip install -r requirements.txt
    echo %GREEN%Basic dependencies installed%NC%
)

:: Check for .env file
echo.
echo [6/6] Checking environment configuration...
if not exist ".env" (
    echo %YELLOW%.env file not found!%NC%
    echo Creating .env template...
    (
        echo # MySQL Database Configuration
        echo MYSQL_HOST=localhost
        echo MYSQL_PORT=3306
        echo MYSQL_DB=your_database_name
        echo MYSQL_USER=your_username
        echo MYSQL_PASSWORD=your_password
        echo.
        echo # Flask Configuration
        echo FLASK_ENV=development
        echo FLASK_DEBUG=True
        echo SECRET_KEY=your-secret-key-here
    ) > .env
    echo %GREEN%.env template created%NC%
    echo %RED%IMPORTANT: Please edit the .env file with your database credentials!%NC%
) else (
    echo %GREEN%.env file exists%NC%
)

:: Final message
echo.
echo ========================================================
echo          Setup completed successfully! 
echo ========================================================
echo.
echo Next steps:
echo   1. Configure your database credentials in the .env file
echo   2. Make sure your MySQL database is running
echo   3. Run the application using: run.bat
echo.
echo To start the application now, run: run.bat
echo.
pause