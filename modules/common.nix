{ config, pkgs, ... }:
{
  # -------------------------------------------------------
  # Allow unfree packages (Discord, Chrome, etc.)
  # -------------------------------------------------------
  nixpkgs.config.allowUnfree = true;

  # -------------------------------------------------------
  # Nix settings
  # -------------------------------------------------------
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # -------------------------------------------------------
  # Locale & timezone
  # -------------------------------------------------------
  time.timeZone = "Europe/Warsaw";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT    = "pl_PL.UTF-8";
    LC_MONETARY       = "pl_PL.UTF-8";
    LC_NAME           = "pl_PL.UTF-8";
    LC_NUMERIC        = "pl_PL.UTF-8";
    LC_PAPER          = "pl_PL.UTF-8";
    LC_TELEPHONE      = "pl_PL.UTF-8";
    LC_TIME           = "pl_PL.UTF-8";
  };

  # -------------------------------------------------------
  # Networking
  # -------------------------------------------------------
  networking.networkmanager.enable = true;

  # Bluetooth on KDE / for other DE  = bluemans
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        AutoEnable = true;
      };
    };
  };

  boot.kernelModules = [ "btusb" ];

  # Added custom fix with firmware RTL8822B/BE for BT on e485
  hardware.firmware = [
    (pkgs.runCommand "rtl8822b-local-fw" { } ''
      mkdir -p $out/lib/firmware/rtlwifi
      mkdir -p $out/lib/firmware/rtl_bt

      # Wi-Fi firmware
      cp ${../firmware/rtlwifi/rtl8822befw.bin} \
         $out/lib/firmware/rtlwifi/rtl8822befw.bin

      # Bluetooth firmware, change firmware fix for rtl8822b_fw.bin on e485
      cp ${../firmware/rtl_bt/rtl8822b_fw.bin} \
         $out/lib/firmware/rtl_bt/rtl8822b_fw.bin
    '')
  ];

  # -------------------------------------------------------
  # User
  # -------------------------------------------------------
  users.users.cyc = {
    isNormalUser = true;
    description  = "cyc";
    extraGroups  = [ "wheel" "networkmanager" "audio" "video" "docker" ];
    # hashedPassword ...
  };

  # -------------------------------------------------------
  # SSH
  # -------------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin        = "no";
    };
  };

  # -------------------------------------------------------
  # Sound — PipeWire (modern replacement for PulseAudio)
  # -------------------------------------------------------
  services.pulseaudio.enable = false;
  security.rtkit.enable     = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = true;
  };

  # -------------------------------------------------------
  # Printing
  # -------------------------------------------------------
  services.printing.enable = true;

  # -------------------------------------------------------
  # System state version — do not change after install
  # -------------------------------------------------------
  system.stateVersion = "25.11";
}