# Packer Vmware Template 

## Contents
* Introduction
* Requirements
* Installation
* Configuration

### INTRODUCTION
Packer templates for building VMware Images from Ubuntu ISOs

## WHAT IT DOES
* Download the Ubuntu ISO.
* Creates a Vmware virtual machine.
* Builds the image with packer using automated installs (preseed file).
* Converts VM to template and stores is specified folder.

### Requirements

The build script is designed to run in a vcenter environment using vcenter APIs. The following prerequisites should be installed on the control host with access to VCenter server url.
* Install [packer](https://www.packer.io/downloads)
* Install [j2cli](https://pypi.org/project/j2cli)
* Install [ansible](https://github.com/ansible/ansible)
* Install [inspec](httos://github.com/inspec/inspec)

### Installation

1. Clone the repo
2. edit the `build.conf` fle and add variables for the packer config file
3. Run `build.sh deploy`

### Configuration
Configurable parameters
* ssh_username
* vcenter_server
* datastore
* folder
* cluster
* resource_pool
* network

ENVIRONMENTAL VARIABLES
-----------------------
Enter passwords when prompted or provide them via ENV Variables
```bash
export vcenter_username=candycorn
export vcenter_password=candyworm
export ssh_username=candybear
export ssh_password=candyfrog
```


OTHERS
------
The create-env script creates a python virtual environment where you can run the deployment.
The dockerfile creates a docker image with ansible, packer and inspect for dockerized deployments.

