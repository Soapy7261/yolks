#!/bin/ash
#sleep 2 lets see why this is needed!

cd /home/container
#MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')` dont need this

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Run the Server
echo "Upgrading pip..."
pip install -q --user --upgrade pip
echo "Installing requirements..."
pip install -q --user -r requirements.txt
echo "Running main.py!"
python main.py
echo "Exiting..."
