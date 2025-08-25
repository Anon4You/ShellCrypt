#!/bin/bash
# install_dependencies.sh

echo "Installing required dependencies for ShellCrypt..."

# Check if we're in Termux
if command -v termux-setup-storage &> /dev/null; then
    IS_TERMUX=true
    echo "Termux environment detected"
else
    IS_TERMUX=false
    echo "Linux/macOS environment detected"
fi

# Install Python and Node.js based on environment
if [ "$IS_TERMUX" = true ]; then
    # Termux installation
    echo "Installing Python and Node.js for Termux..."
    pkg update -y
    pkg install -y python nodejs
    
    # Set python command
    PYTHON_CMD="python"
else
    # Linux/macOS installation
    echo "Installing Python3 and Node.js for Linux/macOS..."
    
    # Install Python3
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y python3 python3-pip nodejs npm
    elif command -v yum &> /dev/null; then
        sudo yum install -y python3 python3-pip nodejs npm
    elif command -v brew &> /dev/null; then
        brew install python3 nodejs
    else
        echo "Error: Package manager not found. Please install Python3 and Node.js manually."
        exit 1
    fi
    
    # Set python command
    PYTHON_CMD="python3"
fi

# Install bash-obfuscate
if ! command -v bash-obfuscate &> /dev/null; then
    echo "Installing bash-obfuscate..."
    if command -v npm &> /dev/null; then
        npm install -g bash-obfuscate
    else
        echo "Error: npm is not installed. Please install Node.js first."
        exit 1
    fi
else
    echo "bash-obfuscate is already installed"
fi

# Install emojify (Python package)
if ! $PYTHON_CMD -m pip show emojify &> /dev/null; then
    echo "Installing emojify package for Python..."
    $PYTHON_CMD -m pip install emojify
else
    echo "emojify package is already installed"
fi

# Install figlet for banner
if ! command -v figlet &> /dev/null; then
    echo "Installing figlet for banner..."
    if [ "$IS_TERMUX" = true ]; then
        pkg install -y figlet
    else
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y figlet
        elif command -v yum &> /dev/null; then
            sudo yum install -y figlet
        elif command -v brew &> /dev/null; then
            brew install figlet
        else
            echo "Warning: figlet not installed and package manager not found. Banner will use fallback ASCII art."
        fi
    fi
else
    echo "figlet is already installed"
fi

# Verify installations
echo -e "\nVerifying installations..."
if command -v bash-obfuscate &> /dev/null; then
    echo -e "✓ bash-obfuscate: $(which bash-obfuscate)"
else
    echo -e "✗ bash-obfuscate: NOT FOUND"
fi

if $PYTHON_CMD -m pip show emojify &> /dev/null; then
    echo -e "✓ emojify: INSTALLED"
else
    echo -e "✗ emojify: NOT FOUND"
fi

if command -v figlet &> /dev/null; then
    echo -e "✓ figlet: $(which figlet)"
else
    echo -e "✗ figlet: NOT FOUND (using fallback)"
fi

echo -e "\nDependencies installed successfully!"
echo "You can now use ShellCrypt with: ./shellcrypt.sh"
