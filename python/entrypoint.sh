#!/bin/ash

TZ=${TZ:-UTC}
export TZ

cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'` # you're on the chopping block buddy

# Run the Program
echo "Upgrading pip..."
pip install --user --upgrade pip
echo "Installing requirements..."
pip install --user -r requirements.txt
echo "Running main.py!"
python main.py
echo "Exiting..."
