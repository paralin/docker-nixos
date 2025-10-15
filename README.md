# Docker NixOS

[![Docker Image](https://img.shields.io/badge/ghcr.io-docker--nixos-blue?logo=docker)](https://github.com/skiffos/docker-nixos/pkgs/container/docker-nixos)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Run NixOS configurations inside Docker containers with full systemd support. This project enables you to use NixOS module system and declarative configuration for containerized applications.

## Features

- **Multi-architecture support**: Built for both `amd64` and `arm64` platforms
- **Full systemd support**: Run systemd-based services inside containers
- **Declarative configuration**: Use NixOS modules to define your container
- **Flake support**: Load configurations from Nix flakes
- **Reproducible builds**: Leverage Nix's reproducibility for consistent containers

## Quick Start

### Basic Usage

Create a NixOS configuration file:

```nix
# nginx.nix
{ lib, ... }:

{
  services.nginx.enable = true;
  services.nginx.virtualHosts."127.0.0.1" = {
    root = "/web";
  };

  networking = {
    useHostResolvConf = lib.mkForce false;
  };
}
```

Run it with Docker Compose:

```yaml
services:
  nginx:
    image: ghcr.io/skiffos/docker-nixos:latest
    volumes:
      - type: tmpfs
        target: /run
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
      - ./nginx.nix:/config/configuration.nix
      - ./web:/web
    ports:
      - "80:80"
    cgroup: host
```

### Using Docker CLI

```bash
docker run -d \
  --name nixos-nginx \
  --tmpfs /run \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  -v $(pwd)/nginx.nix:/config/configuration.nix \
  -v $(pwd)/web:/web \
  -p 80:80 \
  --cgroupns=host \
  ghcr.io/skiffos/docker-nixos:latest
```

## Advanced Usage

### Using Nix Flakes

For more complex configurations, you can use Nix flakes instead of a single `configuration.nix` file.

Create an `options.nix` file:

```nix
{
  flakeUrl = "github:MyUser/myflake/main";
  nixosConfiguration = "myConfigurationName";
}
```

Create your flake:

```nix
# flake.nix
{
  description = "My containerized NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.myConfigurationName = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
  };
}
```

Mount the `options.nix` file in your container:

```yaml
services:
  myapp:
    image: ghcr.io/skiffos/docker-nixos:latest
    volumes:
      - type: tmpfs
        target: /run
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
      - ./options.nix:/options.nix
    cgroup: host
```

### Example Configurations

#### PostgreSQL Database

```nix
{ lib, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    enableTCPIP = true;
    authentication = ''
      host all all 0.0.0.0/0 md5
    '';
  };

  networking.useHostResolvConf = lib.mkForce false;
}
```

#### Redis Cache

```nix
{ lib, ... }:

{
  services.redis.servers."" = {
    enable = true;
    bind = "0.0.0.0";
  };

  networking.useHostResolvConf = lib.mkForce false;
}
```

## Requirements

### Host System

- Docker with cgroup v2 support
- Linux kernel (tested on recent versions)

### Container Runtime

The container requires:
- `/run` mounted as tmpfs
- `/sys/fs/cgroup` mounted from host with read-write access
- `--cgroupns=host` or `cgroup: host` in Docker Compose

These requirements are necessary for running systemd inside the container.

## How It Works

1. **Build Stage**: The Dockerfile builds NixOS from source in an Ubuntu container, compiling Nix and all dependencies
2. **Runtime Stage**: A minimal `FROM scratch` image contains only the built NixOS system
3. **Configuration**: On container startup, the provided `configuration.nix` or flake is evaluated and built
4. **Init**: systemd (`/init`) starts and manages services according to your configuration

## Limitations

- **Build time**: When the container first starts, it builds the provided configuration. This can take several minutes and logs are not forwarded to stdout
- **systemd requirement**: Some NixOS modules may not work correctly in a containerized systemd environment
- **cgroup dependency**: Must run with host cgroups mounted
- **Platform support**: Built for Linux only (amd64 and arm64). Windows and macOS hosts require Docker Desktop with WSL2/virtualization

## Building from Source

Clone the repository and build:

```bash
git clone https://github.com/skiffos/docker-nixos.git
cd docker-nixos
docker build -t docker-nixos .
```

Multi-platform builds are configured via GitHub Actions and can be triggered on push to the `main` branch.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - see [LICENSE](LICENSE) file for details.
