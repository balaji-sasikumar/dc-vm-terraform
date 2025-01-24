provider "azurerm" {
  features {}
}

# Variables for VM details
variable "vm_ip" {
  description = "Public IP of the Azure VM"
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key file"
  default     = "datacenter.pem"
}

variable "admin_username" {
  description = "Admin username for the Azure VM"
  default     = "azureuser"
}

# Remote Provisioner to Install Docker
resource "null_resource" "install_docker" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.vm_ip
      user        = var.admin_username
      private_key = file(var.ssh_private_key_path)
    }

    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce",
      "sudo usermod -aG docker ${USER}",
      "sudo systemctl start docker",
      "sudo systemctl enable docker"
    ]
  }
}
