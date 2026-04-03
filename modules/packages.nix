{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [

    # -------------------------------------------------------
    # Development
    # -------------------------------------------------------
    git
    vscodium
    neovim

    # -------------------------------------------------------
    # Browsers
    # -------------------------------------------------------
    firefox-esr
    brave
    google-chrome    # requires allowUnfree = true

    # -------------------------------------------------------
    # Office & Documents
    # -------------------------------------------------------
    libreoffice-qt   # Qt version — fits better with KDE Plasma
    # okular          # already included with KDE Plasma

    # -------------------------------------------------------
    # Multimedia
    # -------------------------------------------------------
    vlc
    krita

    # -------------------------------------------------------
    # File management
    # -------------------------------------------------------
    krusader         # dual-panel file manager (Total Commander alternative)

    # Ark backends — required for full archive format support
    # ark itself is already included with KDE Plasma
    zip              # ZIP creation
    unzip            # ZIP extraction
    p7zip            # 7z support (read + write)
    unar             # RAR read — free/open-source alternative to unrar
    unrar            # RAR read + write — proprietary, requires allowUnfree = true
    libarchive       # TAR, GZ, BZ2, XZ, ZSTD and more

    # -------------------------------------------------------
    # Communication
    # -------------------------------------------------------
    discord          # requires allowUnfree = true

    # -------------------------------------------------------
    # System & monitoring
    # -------------------------------------------------------
    btop             # modern resource monitor
    htop             # classic process viewer
    fastfetch
    
    # -------------------------------------------------------
    # Network & security
    # -------------------------------------------------------
    wget
    curl
    nmap
    openssh

    # -------------------------------------------------------
    # Terminal utilities
    # -------------------------------------------------------
    ripgrep          # fast grep — used by VSCodium search
    fzf              # fuzzy finder
    tree             # directory tree view

  ];

  # -------------------------------------------------------
  # VSCodium — enable with Open VSX marketplace
  # -------------------------------------------------------
  programs.vscode = {
    enable  = true;
    package = pkgs.vscodium;
  };
}
