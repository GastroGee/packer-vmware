#!/usr/bin/env bash
## Variables ares sourced from the build.conf and passed as environmental variables to packer.
## using J2 to parse the template file and replacing variables where neccessary

set -o allexport
build_conf=build.conf
template_name="${PWD}/server.pkr.hcl"

function help {
    printf "\n"
    echo "$0 (deploy|debug)"
    echo 
    echo "[task]"
    echo "deploy - Build and create the VNware template"
    echo "debug - Build in debug mode"
    echo
    echo
    echo "export vcenter_password=YourLoginPassword"
    echo "export ssh_password=VMPassword"
    printf "\n"
    exit 0
}

function missing_var {
    echo "ERROR: Variable '$1' is required to be set. Please edit '${build_conf}' and set."
    exit 1
}

## Check prerequisites are installed
[[ $(packer --version) ]] || { echo "Please install 'Packer'"; exit 1; }
[[ $(ansible --version) ]] || { echo "Please install 'Ansible'"; exit 1; }
[[ $(j2 -h) ]] || { echo "Please install 'j2cli'"; exit 1; }

## Check build mode 
task=${1:-}
[[ "${1}" == "deploy" ]] || [[ "${1}" == "debug" ]] || help

## Validate variables in build.conf
[[ -f $build_conf ]] || { echo "User variables file '$build_conf' not found"; exit 1; }
source $build_conf

[[ -z "${vcenter_server}" ]] && missing_var "vcenter_server"
[[ -z "${datastore}" ]] && missing_var "datastore"
[[ -z "${folder}" ]] && missing_var "folder"
[[ -z "${cluster}" ]] && missing_var "cluster"
[[ -z "${resource_pool}" ]] && missing_var "resource_pool"
[[ -z "${network}" ]] && missing_var "network"

## Some passwords are set in Environmental Variables, if not set ....prompt for them
[[ -z "${vcenter_username}" ]] && printf "\n" && read -srp "Vcenter Login Username: " vcenter_username && printf "\n"
printf "\n"
[[ -z "${vcenter_password}" ]] && printf "\n" && read -srp "Vcenter Login Password: " vcenter_password && printf "\n"
printf "\n"
if [[ -z "${ssh_password}" ]]; then
    while true; do 
        read -srp "Enter new SSH Password: " ssh_password
        printf "\n"
        read -srp "Enter new SSH Password: " ssh_password2
        printf "\n"
        [ "${ssh_password}" = "${ssh_password2}" ] && break
        printf "Passwords do not match. Try again! \n\n"
    done
fi 

mkdir -p http

## Use j2cli to replace variables in jinja template 
if [[ -f preseed.cfg.j2 ]]; then    
    printf "\n Customizing preseed.cfg \n"
    j2 preseed.cfg.j2 > http/preseed.cfg
    [[ -f http/preseed.cfg ]] || { echo "Customized preseed file not found."; exit 1; }
fi 

## Finally Call Packer Build with all these variables
case ${task} in
    deploy)
        printf "\n Build and Create a VMware Template. \n\n"
        packer build -force "${template_name}"
        status=$?
        ;;
    debug)
        printf "\n Build and Create VMWare Template In Debug Mode. \n\n"
        PACKER_LOG=1 packer build -debug -on-error=ask -force "${template_name}"
        status=$?
        ;;
    *)
        help
        ;;
esac

## Remove Files with Passwords
[[ -f http/preseed.cfg ]] && printf "removing preseed file" && rm -v http/preseed.cfg

exit ${status}





