#!/bin/ash

TZ=${TZ:-UTC}
export TZ

cd /home/container || exit 1

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP # Don't know why this would be needed but okay ig :shrug:

# Run the Program
echo "Upgrading pip..."
pip install --user --upgrade pip
echo "Installing requirements..."
pip install --user -r requirements.txt -U
echo "Running main.py!"
python main.py
echo "Exiting..."
