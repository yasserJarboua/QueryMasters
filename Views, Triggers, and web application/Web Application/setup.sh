#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║   MNHS Hospital Management System - Setup Script      ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if Python is installed
echo -e "${YELLOW}[1/6] Checking Python installation...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed. Please install Python 3.8 or higher.${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | awk '{print $2}')
echo -e "${GREEN}✓ Python $PYTHON_VERSION found${NC}"

# Check if pip is installed
echo -e "\n${YELLOW}[2/6] Checking pip installation...${NC}"
if ! command -v pip3 &> /dev/null; then
    echo -e "${RED}❌ pip3 is not installed. Please install pip3.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ pip3 found${NC}"

# Check if virtual environment exists
echo -e "\n${YELLOW}[3/6] Checking virtual environment...${NC}"
if [ -d "venv" ]; then
    echo -e "${GREEN}✓ Virtual environment already exists${NC}"
    read -p "Do you want to recreate it? (y/N): " recreate
    if [[ $recreate =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Removing existing virtual environment...${NC}"
        rm -rf venv
        echo -e "${YELLOW}Creating new virtual environment...${NC}"
        python3 -m venv venv
        echo -e "${GREEN}✓ Virtual environment created${NC}"
    fi
else
    echo -e "${YELLOW}Creating virtual environment...${NC}"
    python3 -m venv venv
    echo -e "${GREEN}✓ Virtual environment created${NC}"
fi

# Activate virtual environment
echo -e "\n${YELLOW}[4/6] Activating virtual environment...${NC}"
source venv/bin/activate
echo -e "${GREEN}✓ Virtual environment activated${NC}"

# Install dependencies
echo -e "\n${YELLOW}[5/6] Installing dependencies...${NC}"
if [ -f "requirements.txt" ]; then
    pip install --upgrade pip
    pip install -r requirements.txt
    echo -e "${GREEN}✓ Dependencies installed successfully${NC}"
else
    echo -e "${RED}❌ requirements.txt not found!${NC}"
    echo -e "${YELLOW}Creating requirements.txt with basic dependencies...${NC}"
    cat > requirements.txt << EOF
Flask==3.0.0
Flask-SQLAlchemy==3.1.1
python-dotenv==1.0.0
PyMySQL==1.1.0
cryptography==41.0.7
EOF
    pip install -r requirements.txt
    echo -e "${GREEN}✓ Basic dependencies installed${NC}"
fi

# Check for .env file
echo -e "\n${YELLOW}[6/6] Checking environment configuration...${NC}"
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠ .env file not found!${NC}"
    echo -e "${BLUE}Creating .env template...${NC}"
    cat > .env << EOF
# MySQL Database Configuration
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_DB=your_database_name
MYSQL_USER=your_username
MYSQL_PASSWORD=your_password

# Flask Configuration
FLASK_ENV=development
FLASK_DEBUG=True
SECRET_KEY=your-secret-key-here
EOF
    echo -e "${GREEN}✓ .env template created${NC}"
    echo -e "${RED}⚠ IMPORTANT: Please edit the .env file with your database credentials before running the app!${NC}"
else
    echo -e "${GREEN}✓ .env file exists${NC}"
fi

# Final message
echo -e "\n${GREEN}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║            Setup completed successfully! 🎉            ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Configure your database credentials in the ${YELLOW}.env${NC} file"
echo -e "  2. Make sure your MySQL database is running"
echo -e "  3. Run the application using one of these commands:"
echo -e "     ${GREEN}• ./run.sh${NC}                    (Recommended)"
echo -e "     ${GREEN}• source venv/bin/activate${NC}   (Then run: python main.py)"
echo ""
echo -e "${YELLOW}To start the application now, run:${NC} ${GREEN}./run.sh${NC}"
echo ""