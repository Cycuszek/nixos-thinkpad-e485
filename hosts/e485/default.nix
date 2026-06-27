{ config, pkgs, ... }:
{
  networking.hostName = "e485";

  # -------------------------------------------------------
  # Boot - Lenovo ThinkPad E485 specific fixes
  # Required to fix silent hang after EFI stub initrd load
  # when installed via Ventoy
  # -------------------------------------------------------
  boot.initrd.availableKernelModules = [
    "nvme"        # critical - NVMe root partition access
    "xhci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
    "amdgpu"
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];

  boot.kernelParams = [
    "ivrs_ioapic[32]=00:14.0"          # IOAPIC mapping fix for AMD/Lenovo firmware
    "spec_store_bypass_disable=prctl"  # Spectre v4 mitigation - prctl mode (balanced)
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Keep last 5 generations in boot menu
  boot.loader.systemd-boot.configurationLimit = 5;

  # -------------------------------------------------------
  # Hardware - AMD GPU & firmware
  # -------------------------------------------------------
  hardware.amdgpu.initrd.enable = true;    # load amdgpu in initrd
  hardware.amdgpu.opencl.enable = true;    # OpenCL support
  hardware.enableRedistributableFirmware = true; # allow non-free firmware blobs[web:90]

  # -------------------------------------------------------
  # Bluetooth - Realtek RTL8822B firmware quirk workaround
  # -------------------------------------------------------
  # Some RTL8822B/BE controllers only work after a suspend/resume
  # due to a firmware download error during cold boot.
  # This one-shot service suspends the system once after boot.
  # You wake the laptop (lid / power button) and Bluetooth works
  # for the rest of the session without manual suspend.
  systemd.services.auto-suspend-once = {
    description = "Suspend once after boot (Realtek RTL8822B workaround)";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl suspend";
    };
  };
}