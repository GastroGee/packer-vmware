consul_version="1.10.2"
vault_version="1.8.2"
consul_template_version="0.27.0"
golang_version="1.16"
inspec_version="4.31.1-1"
docker_script=get-docker.sh

### Hashicorp Functions
install_hashicorp_binaries () {

    # check consul binary
    [ -f /usr/local/bin/consul ] &>/dev/null || {
        pushd /usr/local/bin || exit
        [ -f consul_${consul_version}_linux_amd64.zip ] || {
            sudo wget -q https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip
        }
        sudo unzip consul_${consul_version}_linux_amd64.zip
        sudo chmod +x consul
        sudo rm consul_${consul_version}_linux_amd64.zip
        popd || exit
    }

    # check consul-template binary
    [ -f /usr/local/bin/consul-template ] &>/dev/null || {
        pushd /usr/local/bin || exit
        [ -f consul-template_${consul_template_version}_linux_amd64.zip ] || {
            sudo wget -q https://releases.hashicorp.com/consul-template/${consul_template_version}/consul-template_${consul_template_version}_linux_amd64.zip
        }
        sudo unzip consul-template_${consul_template_version}_linux_amd64.zip
        sudo chmod +x consul-template
        sudo rm consul-template_${consul_template_version}_linux_amd64.zip
        popd || exit
    }

    # check vault binary
    [ -f /usr/local/bin/vault ] &>/dev/null || {
        pushd /usr/local/bin || exit
        [ -f vault_${vault_version}_linux_amd64.zip ] || {
            sudo wget -q https://releases.hashicorp.com/vault/${vault_version}/vault_${vault_version}_linux_amd64.zip
        }
        sudo unzip vault_${vault_version}_linux_amd64.zip
        sudo chmod +x vault
        sudo rm vault_${vault_version}_linux_amd64.zip
        popd || exit
    }
   
}

## Function to install inspec
install_chef_inspec () {
    [ -f /usr/bin/inspec ] &>/dev/null || {
        pushd /tmp || exit
        curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P inspec -v ${inspec_version}
        popd || exit
    }
}

## Function to install docker
install_docker () {
    [ -f /usr/bin/docker ] &>/dev/null || {
        pushd /tmp
        [ -f ${docker_script} ] || {
            curl -fsSL https://get.docker.com -o get-docker.sh
        }
        sudo sh get-docker.sh
        sudo rm ${docker_script}
        popd
    }
}

echo "Installing hashicorp binaries ...."
install_hashicorp_binaries
echo "Installing inspec ...."
install_chef_inspec
echo "Installing node_exporter...."
install_node_exporter
echo "Installing docker ....."
install_docker


## install golang
which /usr/local/go &>/dev/null || {
    mkdir -p /tmp/go_src
    pushd /tmp/go_src || exit
    [ -f go${golang_version}.linux-amd64.tar.gz ] || {
        wget -qnv https://dl.google.com/go/go${golang_version}.linux-amd64.tar.gz
    }
    sudo tar -C /usr/local -xzf go${golang_version}.linux-amd64.tar.gz
    popd || exit
    rm -rf /tmp/go_src
    sudo bash -c 'echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile'
}

echo "Done with additional packages ....."

exit 0
