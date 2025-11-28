#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║   MNHS Hospital Management System - Starting...       ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo -e "${RED}❌ Virtual environment not found!${NC}"
    echo -e "${YELLOW}Please run ./setup.sh first${NC}"
    exit 1
fi

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ .env file not found!${NC}"
    echo -e "${YELLOW}Please create and configure your .env file${NC}"
    exit 1
fi

# Activate virtual environment
echo -e "${YELLOW}Activating virtual environment...${NC}"
source venv/bin/activate

# Check if main.py exists
if [ ! -f "main.py" ]; then
    echo -e "${RED}❌ main.py not found!${NC}"
    exit 1
fi

# Start the application
echo -e "${GREEN}✓ Starting Flask application...${NC}"
echo -e "${BLUE}Press Ctrl+C to stop the server${NC}"
echo ""

python main.py