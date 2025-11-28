# 🏥 MNHS Hospital Management System

A modern, dark-themed hospital management system built with Flask and MySQL. This system helps manage patients, staff, appointments, and inventory across multiple hospital locations.

![Python](https://img.shields.io/badge/python-3.8+-blue.svg)
![Flask](https://img.shields.io/badge/flask-3.0.0-green.svg)
![MySQL](https://img.shields.io/badge/mysql-8.0+-orange.svg)

## ✨ Features

- 📊 **Dashboard**: Real-time statistics and key metrics
- 👥 **Patient Management**: Add, view, and manage patient records
- 👨‍⚕️ **Staff Analytics**: Track staff workload and appointment distribution
- 💊 **Inventory Management**: Monitor medication stock levels with low-stock alerts
- 🎨 **Modern UI**: Sleek dark theme
- 🔐 **Secure**: Environment-based configuration for database credentials

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Python 3.8 or higher** - [Download Python](https://www.python.org/downloads/)
- **MySQL 8.0 or higher** - [Download MySQL](https://dev.mysql.com/downloads/)
- **Git** (optional) - [Download Git](https://git-scm.com/downloads/)

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)

#### For Linux/Mac:

```bash
# Clone the repository
git clone <your-repo-url>
cd hospital-management-system

# Make scripts executable
chmod +x setup.sh run.sh

# Run setup
./setup.sh

# Configure your database in .env file
nano .env  # or use your preferred text editor

# Run the application
./run.sh
```

#### For Windows:

```batch
# Clone the repository
git clone https://github.com/yasserJarboua/QueryMasters/edit/main/Web%20Application/
cd Web\ Application

# Run setup
setup.bat

# Configure your database in .env file
notepad .env

# Run the application
run.bat
```

### Option 2: Manual Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yasserJarboua/QueryMasters/edit/main/Web%20Application/
   cd Web\ Application
   ```

2. **Create Virtual Environment**
   ```bash
   # Linux/Mac
   python3 -m venv venv
   source venv/bin/activate

   # Windows
   python -m venv venv
   venv\Scripts\activate
   ```

3. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set Up MySQL Database**
   
   Create a priviliged user to the MNHS database

6. **Configure Environment Variables**
   
   Create a `.env` file in the project root:
   ```env
   # MySQL Database Configuration
   MYSQL_HOST=localhost
   MYSQL_PORT=3306
   MYSQL_DB=your_database_name
   MYSQL_USER=your_username
   MYSQL_PASSWORD=your_password
   ```

8. **Run the Application**
   ```bash
   python main.py
   ```

9. **Access the Application**
   
   Open your browser and navigate to: `http://127.0.0.1:5000`

## 📁 Project Structure

```
hospital-management-system/
│
├── main.py                 # Flask application entry point
├── database.py            # Database operations and queries
├── requirements.txt       # Python dependencies
├── .env                   # Environment variables (create this)
├── setup.sh              # Linux/Mac setup script
├── setup.bat             # Windows setup script
├── run.sh                # Linux/Mac run script
├── run.bat               # Windows run script
│
├── templates/            # HTML templates
│   ├── base.html
│   ├── index.html
│   ├── patients.html
│   ├── add_patient.html
│   ├── staff_share.html
│   ├── low_stock.html
│   └── dashboard.html
│
└── static/              # Static assets
    ├── css/
    │   └── style.css    # Main stylesheet
    └── js/
        ├── patients.js
        ├── add_patient.js
        ├── staff.js
        ├── inventory.js
        └── dashboard.js
```

## 🔧 Configuration

### Database Configuration

Edit the `.env` file with your MySQL credentials:

```env
MYSQL_HOST=localhost        # Database host
MYSQL_PORT=3306            # Database port
MYSQL_DB=hospital_db       # Your database name
MYSQL_USER=root            # Your MySQL username
MYSQL_PASSWORD=password    # Your MySQL password
```

## 📊 Database Schema Requirements

Your MySQL database should have (at least optionaly it should matche exactly the MNHS DB schema) the following tables:

- **Patient**: Patient information
- **Staff**: Staff/doctor information
- **Hospital**: Hospital locations
- **Department**: Hospital departments
- **ClinicalActivity**: Clinical activities and appointments
- **Appointment**: Appointment details
- **Medication**: Medication catalog
- **Stock**: Medication inventory per hospital

## 🎯 Features Guide

### Dashboard
- View total patients, staff, appointments, and low-stock items
- See recent patient registrations
- Monitor critical stock items

### Patient Management
- View all patients sorted by last name
- Add new patient records with comprehensive information
- Quick access to patient details

### Staff Analytics
- Track appointment distribution per staff member
- View workload percentages per hospital
- Identify top-performing staff

### Inventory Management
- Monitor medication stock levels
- Automatic low-stock alerts
- View stock status across all hospitals

## 🛠️ Troubleshooting

### Common Issues

**Issue: "ModuleNotFoundError: No module named 'flask'"**
- Solution: Make sure you've activated the virtual environment and installed dependencies
  ```bash
  source venv/bin/activate  # Linux/Mac
  pip install -r requirements.txt
  ```

**Issue: "Can't connect to MySQL server"**
- Solution: Verify MySQL is running and credentials in `.env` are correct
  ```bash
  # Check if MySQL is running
  sudo service mysql status  # Linux
  brew services list         # Mac
  ```

**Issue: "Access denied for user"**
- Solution: Check your MySQL username and password in the `.env` file

**Issue: "Table doesn't exist"**
- Solution: Make sure you've created all required tables in your database using your SQL schema

### Getting Help

If you encounter issues:
1. Check the console output for error messages
2. Verify all prerequisites are installed
3. Ensure your `.env` file is configured correctly
4. Make sure your MySQL database is running


## 🙏 Acknowledgments

- Flask framework for the backend
- Modern dark theme inspired by contemporary web design


**Note**: Remember to never commit your `.env` file to version control. Add it to `.gitignore`:

```gitignore
# .gitignore
venv/
__pycache__/
*.pyc
.env
*.db
.DS_Store
```
