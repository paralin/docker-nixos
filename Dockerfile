# Use Ubuntu Rolling instead of Arch Linux to support arm64 builds,
# as Arch Linux does not provide official arm64 images.
FROM ubuntu:rolling AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      build-essential \
      wget \
      ca-certificates \
      pkg-config \
      autoconf-archive \
      jq \
      sudo \
      bison \
      flex \
      ninja-build \
      bmake \
      cmake \
      libboost-all-dev \
      libedit-dev \
      libsodium-dev \
      libgtest-dev \
      libgmock-dev \
      librapidcheck-dev \
      nlohmann-json3-dev \
      libarchive-dev \
      libsqlite3-dev \
      libcurl4-openssl-dev \
      libbrotli-dev \
      libseccomp-dev \
      libgc-dev \
      libssh2-1-dev \
      libtoml11-dev \
      libdbi-perl \
      libdbd-sqlite3-perl \
      libperl-dev \
      libgit2-dev \
      liblowdown-dev \
      librust-blake3-dev \
      libtool \
      python3 \
      curl \
      meson && \
    apt-get clean

RUN groupadd nixbld && \
    useradd --home /home/builder --shell /bin/bash builder && \
    usermod -a -G nixbld builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder && \
    chmod 600 /etc/sudoers.d/builder && \
    mkdir -p /home/builder/sys-config /home/builder/scripts

ADD ./editline-setup.sh /home/builder/scripts/
RUN chmod +x /home/builder/scripts/editline-setup.sh && \
    chown -R builder /home/builder && \
    sudo -u builder bash -c "cd /home/builder && bash ./scripts/editline-setup.sh"

ADD ./blake3-setup.sh /home/builder/scripts/
RUN chmod +x /home/builder/scripts/blake3-setup.sh && \
    sudo -u builder bash -c "cd /home/builder && bash ./scripts/blake3-setup.sh"

ADD ./nix-setup.sh /home/builder/scripts/
RUN chmod +x /home/builder/scripts/nix-setup.sh && \
    sudo -u builder bash -c "cd /home/builder && bash ./scripts/nix-setup.sh"

ADD ./nixpkgs-setup.sh /home/builder/scripts/
RUN chmod +x /home/builder/scripts/nixpkgs-setup.sh && \
    sudo -u builder bash -c "cd /home/builder && bash ./scripts/nixpkgs-setup.sh"

ADD ./nixos-setup.sh *.nix /home/builder/sys-config/
RUN mkdir -p /sys-root && \
    cd /home/builder/sys-config && bash ./nixos-setup.sh && \
    rm /sys-root/etc && \
    mkdir -m 0755 -p /sys-root/etc/nixos && \
    touch /sys-root/etc/NIXOS && \
    cp /home/builder/sys-config/*.nix /sys-root/etc/nixos/

FROM scratch

STOPSIGNAL SIGRTMIN+3
WORKDIR /
ENV container=docker

COPY --from=builder /nix /nix
COPY --from=builder /sys-root/ /
COPY options.nix /options.nix
COPY container-base-config-flake.nix /baseconfig/flake.nix
COPY configuration.nix /baseconfig/container.nix
COPY config /config

ENTRYPOINT ["/init"]
