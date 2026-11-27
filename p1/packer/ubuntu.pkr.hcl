packer {
    required_plugins {
        qemu = {
            version = ">= 1.0.0"
            source  = "github.com/hashicorp/qemu"
        }
        vagrant = {
            version = ">= 1.0.0"
            source  = "github.com/hashicorp/vagrant"
        }
    }
}

build {
    name = "ubuntu-26.04-arm64"
    sources = ["source.qemu.aharrass"]
    provisioner "shell" {
        execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
        scripts = ["./scripts/cleanup.sh"]
    }
    post-processor "vagrant" {
        output = "../ubuntu-26.04-arm64.box"
    }
}

source "qemu" "aharrass" {
    iso_url = "https://cloud-images.ubuntu.com/minimal/releases/resolute/release-20261118/ubuntu-26.04-minimal-cloudimg-arm64.img"
    iso_checksum = "file:https://cloud-images.ubuntu.com/minimal/releases/resolute/release-20261118/SHA256SUMS"
    disk_image = true
    accelerator = "kvm"
    qemuargs = [["-cpu","host"]]
    cd_files = ["./cloud-init/user-data", "./cloud-init/meta-data"]
    cd_label = "cidata"
    cdrom_interface = "virtio-scsi"
    ssh_username = "vagrant"
    ssh_private_key_file = "/home/aharrass/.vagrant.d/insecure_private_keys/vagrant.key.ed25519"
    qemu_binary = "qemu-system-aarch64"
    machine_type = "virt"
    efi_boot = true
    efi_firmware_code = "/usr/share/AAVMF/AAVMF_CODE.fd"
    efi_firmware_vars = "/usr/share/AAVMF/AAVMF_VARS.fd"
    format = "qcow2"
    disk_size = "10G"
    memory = 1024
    cpus = 1
    headless = false
    shutdown_command = "sudo shutdown -P now"
    ssh_timeout = "10m"
    output_directory = "output-qemu-ubuntu"
    vm_name = "aharrass"
    disk_discard = "unmap"
} 