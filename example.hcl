variable "cluster" {
  type    = string
  default = "dev"
}
variable "datastore" {
  type    = string
  default = "dev"
}
variable "folder" {
  type    = string
  default = "dev"
}
variable "iso_checksum" {
  type    = string
  default = "sha256:f11bda2f2caed8f420802b59f382c25160b114ccc665dbac9c5046e7fceaced2"
}
variable "iso_url" {
  type    = string
  default = "https://cdimage.ubuntu.com/ubuntu-legacy-server/releases/20.04/release/ubuntu-20.04.1-legacy-server-amd64.iso"
}
variable "network" {
  type    = string
  default = "dev"
}
variable "resource_pool" {
  type    = string
  default = "dev"
}

variable "vcenter_password" {
  type    = string
  default = "gastrolee"
}

variable "vcenter_server" {
  type    = string
  default = "https://gastrollc-esx.corp.gastro.com"
}

variable "vcenter_username" {
  type    = string
  default = "gastro"
}

variable "vm_name" {
  type    = string
  default = "ubuntu-2004-template"
}

source "vsphere-iso" "Dev" {
  CPUs                 = "4"
  RAM                  = "4096"
  RAM_reserve_all      = true
  boot_command         = ["<esc><wait>", "<esc><wait>", "<enter><wait>", "/install/vmlinuz<wait>", " initrd=/install/initrd.gz", " priority=critical", " locale=en_US", " file=/media/preseed.cfg", "<enter>"]
  boot_order           = "disk,cdrom"
  convert_to_template  = "true"
  disk_controller_type = ["pvscsi", "pvscsi"]
  floppy_files         = ["http/preseed.cfg"]
  guest_os_type        = "ubuntu64Guest"
  insecure_connection  = "true"
  iso_checksum         = var.iso_checksum
  iso_url              = var.iso_url
  cluster              = var.cluster  
  datastore            = var.datastore
  folder               = var.folder
  configuration_parameters = {
    "disk.EnableUUID" = true
  }
  network_adapters {
    network      = var.network
    network_card = "vmxnet3"
  }
  password      = var.vcenter_password
  resource_pool = var.resource_pool
  ssh_password  = var.ssh_password
  ssh_username  = var.ssh_username
  storage {
    disk_controller_index = 0
    disk_size             = 85000
    disk_thin_provisioned = true
  }
  storage {
    disk_controller_index = 1
    disk_size             = 100000
    disk_thin_provisioned = true
  }

  username       = var.vcenter_username
  vcenter_server = var.vcenter_server
  vm_name        = "Ubuntu-2004-Template"
}

build {
  sources = ["source.vsphere-iso.Dev"]

  provisioner "shell" {
    inline = ["echo 'template build - start configuring ssh access'"]
  }

  provisioner "shell" {
    inline = ["mkdir -p /home/${var.ssh_username}/.ssh"]
  }

  provisioner "shell" {
    inline = ["sudo chown -R ${var.ssh_username}:${var.ssh_username} /home/${var.ssh_username}", "sudo chmod go-w /home/${var.ssh_username}/", "sudo chmod 700 /home/${var.ssh_username}/.ssh"]
  }

  provisioner "shell" {
    inline = ["echo 'template build - disable ssh password access'"]
  }

  provisioner "shell" {
    inline = ["sudo su root -c \"sed '/ChallengeResponseAuthentication/d' -i /etc/ssh/sshd_config | sudo bash\"", "sudo su root -c \"sed '/PasswordAuthentication/d' -i /etc/ssh/sshd_config | sudo bash\"", "sudo su root -c \"sed '/UsePAM/d' -i /etc/ssh/sshd_config | sudo bash\"", "sudo su root -c \"echo  >> /etc/ssh/sshd_config | sudo bash\"", "sudo su root -c \"echo 'ChallengeResponseAuthentication no' >> /etc/ssh/sshd_config | sudo bash\"", "sudo su root -c \"echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config | sudo bash\""]
  }

  provisioner "shell" {
    inline = ["echo 'template build - starting configuration by deploying base packages'"]
  }

  provisioner "shell" {
    execute_command   = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    expect_disconnect = true
    scripts = ["scripts/base.sh", "scripts/installs.sh"]
  }

  provisioner "shell" {
    inline = [
      "sudo bash -c 'echo -n /etc/machine-id'",
      "sudo rm /var/lib/dbus/machine-id",
      "sudo ln -s /etc/machine-id /var/lib/dbus/machine-id"
    ]
  }

