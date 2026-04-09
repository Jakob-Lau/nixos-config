{ self, ... }:
let
  inherit
    (self.inputs)
    nixpkgs
    nixpkgs-unstable
    nixos-hardware
    ;
  nixosSystem = nixpkgs.lib.makeOverridable nixpkgs.lib.nixosSystem;
  overlay-unstable = final: prev: {
    unstable = import nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };

  customModules = import ./core/default.nix;
  baseModules = [
    # make flake inputs accessible in NixOS
    {
      _module.args.self = self;
      _module.args.inputs = self.inputs;
    }
    {
      imports = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            overlay-unstable
            (import ../pkgs)
          ];
          nix.nixPath = [
            "nixpkgs=${pkgs.path}"
          ];
          documentation.info.enable = true;
        })
      ];
    }
    # ../modules
    # ../profiles
  ];
  defaultModules = baseModules ++ customModules;
in
{
  flake.nixosConfigurations = {
    server-jakob = nixosSystem {
      system = "x86_64-linux";
      modules = defaultModules ++ [
        ./server-jakob/configuration.nix
      ];
    };
  };
}
