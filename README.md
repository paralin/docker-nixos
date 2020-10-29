# NixOS Dockerfile

This repository contains a **Dockerfile** of a multi-stage build which produces
a functional NixOS system as the output image.

It uses Ubuntu as an intermediate build environment, which is available for most
architectures. There is a variant for Alpine, but it has issues building - RT34
errors, possibly due to musl.

# Usage

```sh
docker build -t skiffos/skiff-core-nixos:latest .
docker run --privileged -d --name=nix skiffos/skiff-core-nixos:latest
```
    
# License

MIT
