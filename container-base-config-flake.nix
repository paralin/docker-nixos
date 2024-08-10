{
  outputs = { self }: {
    nixosModules.containerConfig = import ./container.nix;
    nixosModule = self.nixosModules.containerConfig;
  };
}
