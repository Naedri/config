#!/bin/bash

# Exit immediately if any command exits with a non-zero status
set -e

echo "=== Starting Python 3.11 Installation and Configuration ==="

# 1. Update system package index
echo "--> Updating system package index..."
sudo apt update

# 2. Install prerequisites for adding external repositories
echo "--> Installing software-properties-common..."
sudo apt install -y software-properties-common

# 3. Add the Deadsnakes PPA for newer Python versions
echo "--> Adding Deadsnakes PPA..."
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update

# 4. Install Python 3.11 and necessary modules
echo "--> Installing Python 3.11, venv, and distutils..."
sudo apt install -y python3.11 python3.11-venv python3.11-distutils

# 5. Detect system's base python3 version to maintain a backup route
DEFAULT_SYS_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
echo "--> Detected default system Python version: $DEFAULT_SYS_VER"

# 6. Configure update-alternatives to make Python 3.11 the default
echo "--> Registering alternatives for 'python3'..."
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/"python$DEFAULT_SYS_VER" 1

# Force update-alternatives to actively select Python 3.11
sudo update-alternatives --set python3 /usr/bin/python3.11

# 7. Install the utility to link plain 'python' to 'python3'
echo "--> Configuring plain 'python' command to route to python3..."
sudo apt install -y python-is-python3

# Verify global installation
echo "--> Global Python Version:"
python --version

# 8. Create and Bootstrap a project virtual environment
echo "--> Setting up a project folder and Python 3.11 Virtual Environment..."
mkdir -p ~/my_python311_project
cd ~/my_python311_project

# Create the virtual environment
python3.11 -m venv venv

# Bootstrap pip inside the isolated environment without needing to activate it first
echo "--> Upgrading pip inside the environment..."
./venv/bin/python -m ensurepip --upgrade
./venv/bin/python -m pip install --upgrade pip

echo "=========================================================="
echo " Setup complete!"
echo " Your global 'python' and 'python3' commands now use 3.11."
echo " Project environment created at: ~/my_python311_project"
echo " To start using your project environment, run:"
echo "   cd ~/my_python311_project && source venv/bin/activate"
echo "=========================================================="
