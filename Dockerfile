FROM ubuntu:focal as builder

# Bootstraps a full NixOS container by building Nix and compiling the config.
# The result is a fully featured NixOS container image.
RUN \
  export DEBIAN_FRONTEND=noninteractive; \
  apt-get update; \
  apt-get install -y \
  --no-install-recommends \
  -o "Dpkg::Options::=--force-confdef"  \
  -o "Dpkg::Options::=--force-confold"  \
  build-essential curl bash git autoconf automake libsqlite3-dev bison libtool \
  flex autoconf-archive libboost-all-dev cmake libcppunit-dev ca-certificates \
  libssl-dev libedit-dev libseccomp-dev jq libarchive-dev wget pkg-config \
  linux-headers-generic docbook-xml docbook-xsl libsodium-dev sudo libbz2-dev \
  libcurl4-openssl-dev liblzma-dev libbrotli-dev && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*

# nyx nyx nyx nyx nyx!
RUN \
  addgroup nixbld && \
  adduser --disabled-password --gecos "" --home /home/builder --shell /bin/bash builder && \
  usermod -a -G nixbld builder && \
  echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder && \
  chmod 600 /etc/sudoers.d/builder && \
  mkdir -p /home/builder/sys-config /home/builder/scripts

ADD ./nix-setup.sh ./editline-setup.sh ./lowdown-setup.sh /home/builder/scripts/
RUN \
  chmod +x /home/builder/scripts/* && \
  chown -R builder /home/builder && \
  sudo -u builder bash -c "cd /home/builder && bash ./scripts/editline-setup.sh"
RUN sudo -u builder bash -c "cd /home/builder && bash ./scripts/lowdown-setup.sh"
RUN sudo -u builder bash -c "cd /home/builder && bash ./scripts/nix-setup.sh"

ADD nixpkgs-setup.sh /home/builder/scripts/
RUN sudo -u builder bash -c "cd /home/builder && bash ./scripts/nixpkgs-setup.sh"

ADD nixos-setup.sh configuration.nix /home/builder/sys-config/
RUN \
  mkdir -p /sys-root && \
  cd /home/builder/sys-config && bash ./nixos-setup.sh

# create the final Docker image using the output of the build.
FROM scratch

WORKDIR /
COPY --from=builder /sys-root/ /
COPY --from=builder /nix/ /nix/
COPY ./configuration.nix ./hardware-configuration.nix /etc/nixos/

ENTRYPOINT ["/init"]
