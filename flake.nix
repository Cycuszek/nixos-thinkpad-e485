{
  description = "NixOS configuration — Lenovo ThinkPad E485";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {

      e485 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/e485/default.nix
          ./hosts/e485/hardware.nix
          ./modules/common.nix
          ./modules/desktop.nix
          ./modules/packages.nix
          ./modules/shell.nix
        ];
      };

      # Future machines can be added here:
      # other-machine = nixpkgs.lib.nixosSystem { ... };

    };
  };
}
