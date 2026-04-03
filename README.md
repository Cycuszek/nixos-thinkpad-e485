# NixOS on Lenovo ThinkPad E485 — Installation Guide

> A step-by-step guide to installing NixOS on the Lenovo ThinkPad E485 (AMD Ryzen / Vega GPU), including fixing the common EFI boot failure after installation via Ventoy.

---

## Hardware

| Component | Spec |
|-----------|------|
| Model | Lenovo ThinkPad E485 |
| CPU | AMD Ryzen (Zen+) |
| GPU | AMD Radeon Vega (integrated) |
| Storage | NVMe SSD |
| Boot | UEFI |

---

## The Problem

After installing NixOS from a Ventoy USB stick, the system boots into the bootloader menu correctly, but then hangs with:

```
EFI stub: Loaded initrd from LINUX_EFI_INITRD_MEDIA_GUID device path
```

This message itself is **not** the error — the system silently hangs after it. The root cause is that the installer (running from Ventoy) does not correctly detect all required kernel modules for the initrd, so the kernel cannot mount the root filesystem after boot.

---

## Installation

### 1. Boot the installer

Flash the NixOS ISO to a USB stick using [Ventoy](https://www.ventoy.net). Boot with these kernel parameters (add them in the GRUB menu by pressing `e`):

```
ivrs_ioapic[32]=00:14.0 spec_store_bypass_disable=prctl
```

These parameters fix IOMMU/IOAPIC mapping issues specific to this AMD platform.

### 2. Install normally

Proceed with the graphical installer as usual (partitioning, user setup, etc.).

---

## Fixing the Boot Failure

After installation, **do not reboot yet** (or boot back into the live ISO if you already rebooted and got stuck).

### Step 1 — Identify your partitions

Open a terminal and run:

```bash
lsblk -f
```

You should see something like:

```
nvme0n1
├─nvme0n1p1   vfat   FAT32          # EFI partition
├─nvme0n1p2   ext4         root     # root partition
└─nvme0n1p3   swap                  # swap
```

### Step 2 — Mount and enter the installed system

```bash
mount /dev/nvme0n1p2 /mnt
mount /dev/nvme0n1p1 /mnt/boot
nixos-enter
```

### Step 3 — Edit the configuration

```bash
nano /etc/nixos/configuration.nix
```

Add or fix the following options. Make sure the option name is `availableKernelModules` (with an **s** at the end — a common typo from the graphical installer):

```nix
# Lenovo E485 — required kernel modules for initrd
boot.initrd.availableKernelModules = [
  "nvme"        # critical — needed to access the NVMe root partition
  "xhci_pci"
  "ahci"
  "usb_storage"
  "sd_mod"
  "amdgpu"
];

boot.initrd.kernelModules = [ "amdgpu" ];

boot.kernelParams = [
  "ivrs_ioapic[32]=00:14.0"
  "spec_store_bypass_disable=prctl"
];

# Bootloader
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
```

Save with `Ctrl+O`, then `Ctrl+X`.

### Step 4 — Rebuild the system

```bash
nixos-rebuild switch
```

> The build will succeed even if you see `Error: Failed to open dbus connection` at the end — this is expected inside `nixos-enter` (no systemd running). The system configuration is built correctly.

### Step 5 — Reinstall the bootloader

```bash
NIXOS_INSTALL_BOOTLOADER=1 /nix/var/nix/profiles/system/bin/switch-to-configuration boot
```

You should see:

```
Copied systemd-bootx64.efi to /boot/EFI/systemd/systemd-bootx64.efi
Copied systemd-bootx64.efi to /boot/EFI/BOOT/BOOTX64.EFI
Created EFI boot entry "Linux Boot Manager".
```

### Step 6 — Reboot

```bash
exit
reboot
```

Remove the Ventoy USB during reboot. The system should now boot into NixOS normally.

---

## Why `nvme` is the key module

When installing via Ventoy, the live system uses its own storage drivers. `nixos-generate-config` may not detect `nvme` as a required initrd module because the installer itself doesn't use it directly. Without `nvme` in `boot.initrd.availableKernelModules`, the kernel loads the initrd successfully (hence the EFI stub message), but then cannot find the root partition — and hangs silently.

---

## Optional: Additional kernel parameters

If the system still freezes after booting, try adding one of these to `boot.kernelParams`:

```nix
"amd_iommu=pt"   # passthrough mode, less strict IOMMU
"nomodeset"      # disable GPU modesetting (for debugging only)
```

---

## References

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Wiki — Bootloader](https://nixos.wiki/wiki/Bootloader)
- [NixOS Wiki — AMD GPU](https://nixos.wiki/wiki/AMD_GPU)
- [NixOS Discourse — EFI stub boot hang](https://discourse.nixos.org/t/system-wont-boot-path-efi-stub/29212)

---

## Contributing

If you have a ThinkPad E485 and found additional fixes or improvements, feel free to open a PR or issue.

---

*Tested with NixOS 25.11 (graphical installer) on Lenovo ThinkPad E485, April 2026.*

---

# Leave HERE if you are not interested in flakes :) *WORK IN PROGRESS*

---
## CHANGE cyc in #common.nix and #shell.nix to YOUR_USERNAME !

## Flake-based Configuration

This repo also contains a full NixOS flake configuration for the ThinkPad E485, ready to use after the initial installation is fixed.

### Repository structure

```
nixos-thinkpad-e485/
├── flake.nix                  # entry point — defines all hosts
├── flake.lock                 # pinned nixpkgs version (auto-generated)
├── hosts/
│   └── e485/
│       ├── default.nix        # E485-specific boot fixes and AMD GPU config
│       └── hardware.nix       # generated by nixos-generate-config
└── modules/
    ├── common.nix             # user, locale, SSH, PipeWire
    ├── desktop.nix            # KDE Plasma 6, Nerd Fonts
    ├── packages.nix           # all applications
    └── shell.nix              # zsh + oh-my-zsh + autosuggestions
```

### Included software

| Category | Packages |
|---|---|
| Browsers | Firefox ESR, Brave, Google Chrome |
| Development | VSCodium, Neovim, Git |
| Office | LibreOffice (Qt) |
| Multimedia | VLC, Krita |
| Files | Krusader, Ark + ZIP/7z/RAR backends |
| Communication | Discord |
| System | btop, htop, nmap, wget, curl, openssh |
| Shell | zsh, oh-my-zsh, autosuggestions, syntax highlighting |

---

## Deploying the Flake Configuration

### Step 1 Git/GitHub

On your installed NixOS system, open a terminal and run:

```bash
# Install git if not already available
nix-shell -p git

# Files correct structure:
# 
# flake.nix
# hosts/e485/default.nix
# hosts/e485/hardware.nix
# modules/common.nix
# modules/desktop.nix
# modules/packages.nix
# modules/shell.nix
```

### Step 2 — Enable flakes

Add this to your current `/etc/nixos/configuration.nix` if not already present:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Apply it:

```bash
sudo nixos-rebuild switch
```

### Step 3 — Rebuild from GitHub

Directly from the remote repo (no clone needed - but u need flag, and lock is not used!):



```bash
sudo nixos-rebuild switch --flake github:Cycuszek/nixos-thinkpad-e485#e485 --no-write-lock-file
```

Or clone locally and rebuild **(recommended — faster, works offline)**:

```bash
git clone https://github.com/Cycuszek/nixos-thinkpad-e485.git ~/nixos-config
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#e485
```

### Step 4 — Set your password

After the first rebuild, set your user password once:

```bash
passwd cyc # CHANGE cyc in #common.nix and #shell.nix to YOUR_USERNAME # if you fork it ;)
```

This survives all future rebuilds — NixOS never touches `/etc/shadow` during rebuild.

### Step 5 — Day-to-day workflow 
## If you fork it ;)

```bash
cd ~/nixos-config
# edit any .nix file
git add . && git commit -m "describe your change"
sudo nixos-rebuild switch --flake .#e485
git push
```

Once you are using zsh, the shell alias `rebuild` (defined in `shell.nix`) runs the rebuild in one word.

---

## Security Note

The `hardware.nix` file contains disk UUIDs. These are **safe to commit publicly** — UUIDs are not passwords or encryption keys. They are visible to anyone who can run `lsblk -f` on the machine.

Never commit to a public repo:
- User passwords or password hashes (`hashedPassword`)
- SSH private keys
- API tokens or secrets
- LUKS encryption keys

---

## Contributing

If you have a ThinkPad E485 and found additional fixes or improvements, feel free to open a PR or issue.

---

*Tested with NixOS 25.11 (graphical installer) on Lenovo ThinkPad E485, April 2026.*
