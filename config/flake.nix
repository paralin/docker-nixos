{
  description = "Container test";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
   };

  outputs = { self, nixpkgs, ... }@inputs: 
   {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
  };
}