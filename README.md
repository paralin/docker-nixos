# NixOS Dockerfile

This repository contains a **Dockerfile** of a multi-stage build which produces
a functional NixOS system as the output image.

It uses alpine as an intermediate build environment, which is available for most architectures.

# Usage

```sh
docker build -t skiffos/skiff-core-nixos:latest .
docker run --privileged -d --name=nix skiffos/skiff-core-nixos:latest
```
    
# License

MIT
