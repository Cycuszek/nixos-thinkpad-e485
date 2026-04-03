{ config, pkgs, ... }:
{
  networking.hostName = "e485";

  # -------------------------------------------------------
  # Boot — Lenovo ThinkPad E485 specific fixes
  # Required to fix silent hang after EFI stub initrd load
  # when installed via Ventoy
  # -------------------------------------------------------
  boot.initrd.availableKernelModules = [
    "nvme"        # critical — NVMe root partition access
    "xhci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
    "amdgpu"
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];

  boot.kernelParams = [
    "ivrs_ioapic[32]=00:14.0"       # IOAPIC mapping fix for AMD/Lenovo firmware
    "spec_store_bypass_disable=prctl" # Spectre v4 mitigation — prctl mode (balanced)
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Keep last 5 generations in boot menu
  boot.loader.systemd-boot.configurationLimit = 5;

  # -------------------------------------------------------
  # Hardware — AMD GPU
  # -------------------------------------------------------
  hardware.amdgpu.initrd.enable = true;    # load amdgpu in initrd
  hardware.amdgpu.opencl.enable = true;    # OpenCL support
  hardware.enableRedistributableFirmware = true;
}
