# FROM quay.io/skiffos/ubuntu:focal as builder
FROM archlinux:base-devel as builder

RUN pacman --noconfirm -Syu
RUN pacman --noconfirm -S shadow wget pkg-config autoconf-archive jq boost boost \
  editline libsodium libcpuid gtest rapidcheck nlohmann-json libgit2
RUN pacman --noconfirm -Scc 

# nyx nyx nyx nyx nyx!
RUN \
  groupadd nixbld && \
  useradd --home /home/builder --shell /bin/bash builder && \
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

ADD nixos-setup.sh *.nix /home/builder/sys-config/
RUN \
  mkdir -p /sys-root && \
  cd /home/builder/sys-config && bash ./nixos-setup.sh && \
  rm /sys-root/etc && \
  mkdir -m 0755 -p /sys-root/etc/nixos && \
  touch /sys-root/etc/NIXOS && \
  cp /home/builder/sys-config/*.nix \
     /sys-root/etc/nixos/ 
  

# create the final Docker image using the output of the build.
FROM scratch

STOPSIGNAL SIGRTMIN+3

WORKDIR /
ENV container docker

COPY --from=builder /nix /nix
COPY --from=builder /sys-root/ /
COPY options.nix /options.nix
COPY container-base-config-flake.nix /baseconfig/flake.nix
COPY configuration.nix /baseconfig/container.nix
COPY config /config

ENTRYPOINT ["/init"]
