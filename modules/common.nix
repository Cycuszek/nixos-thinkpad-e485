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
  #
  # Bluetooth on KDE / for other DE  = bluemans
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # -------------------------------------------------------
  # User
  # -------------------------------------------------------
  users.users.cyc = {
    isNormalUser = true;
    description  = "cyc";
    extraGroups  = [ "wheel" "networkmanager" "audio" "video" "docker" ];

    # Set password on first boot with: passwd cyc
    # Or uncomment and use hashed password (generate with: mkpasswd -m sha-512)
    # hashedPassword = "$6$...";
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
