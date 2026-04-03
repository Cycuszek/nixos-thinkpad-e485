{ config, pkgs, ... }:
{
  # -------------------------------------------------------
  # KDE Plasma 6
  # -------------------------------------------------------
  services.desktopManager.plasma6.enable = true;

  services.displayManager = {
    sddm.enable      = true;
    sddm.wayland.enable = true;
    defaultSession   = "plasma";
  };

  # -------------------------------------------------------
  # Fonts
  # -------------------------------------------------------
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Noto Sans" ];
      serif     = [ "Noto Serif" ];
    };
  };

  # -------------------------------------------------------
  # XDG portal (needed for Flatpak, screen sharing, etc.)
  # -------------------------------------------------------
  xdg.portal.enable = true;
}
