#!/usr/bin/env bash
python3 -m venv packer 
source packer/bin/activate
python3 -m pip install --upgrade ansible==2.10.7 j2cli passlib
echo "virtual environment created, run 'source packer/bin/activate' to user the virtual environment."
