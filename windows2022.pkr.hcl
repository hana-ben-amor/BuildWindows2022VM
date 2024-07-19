variable "boot_wait" {}
variable "disk_size" {}
variable "iso_checksum" {}
variable "iso_url" {}
variable "memsize" {}
variable "numvcpus" {}
variable "vm_name" {}
variable "winrm_password" {}
variable "winrm_username" {}


build {
  sources = ["source.virtualbox-iso.windows2022"]

  provisioner "powershell" {
    only         = ["virtualbox-iso"]
    scripts      = ["scripts/virtualbox-guest-additions.ps1"]
    pause_before = "1m"
  }

  provisioner "powershell" {
    scripts = ["scripts/setup.ps1"]
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
  }
}

source "virtualbox-iso" "windows2022" {
  guest_os_type        = "Windows2022_64"
  vm_name              = var.vm_name
  iso_url              = var.iso_url
  iso_checksum         = var.iso_checksum
  guest_additions_mode = "disable"
  headless             = false
  boot_wait            = var.boot_wait
  disk_size            = var.disk_size
  communicator         = "winrm"
  winrm_username       = var.winrm_username
  winrm_password       = var.winrm_password
  winrm_use_ssl        = true
  winrm_insecure       = true
  winrm_timeout        = "4h"
  floppy_files         = ["scripts/bios/gui/autounattend.xml"]
  shutdown_command     = "shutdown /s /t 5 /f /d p:4:1 /c \"Packer Shutdown\""
  shutdown_timeout     = "30m"

  vboxmanage = [
        ["modifyvm", "{{.Name}}", "--memory", var.memsize],
        ["modifyvm", "{{.Name}}", "--cpus", var.numvcpus]
    ]
  
}
