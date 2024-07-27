#!/bin/ash
echo "Upgrading pip..."
pip install -q --user --upgrade pip
echo "Installing requirements..."
pip install -q --user -r requirements.txt
echo "Running python!"
python main.py
echo "Exiting..."
