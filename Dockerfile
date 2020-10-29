FROM alpine:edge as builder

# Bootstraps a full NixOS container by building Nix and compiling the config.
# The result is a fully featured NixOS container image.

RUN \
  apk add --update --no-cache \
  alpine-sdk sudo curl bash git autoconf automake sqlite-dev curl-dev xz-dev \
  bison flex libtool autoconf-archive boost-dev openssl-dev bzip2-dev \
  libedit-dev libseccomp-dev jq libarchive-dev gc-dev gtest-dev nlohmann-json \
  linux-headers bsd-compat-headers docbook-xml docbook-xsl

# nyx nyx nyx nyx nyx!
RUN \
  addgroup nixbld && \
  adduser -D --home /home/builder --shell /bin/bash --ingroup nixbld builder && \
  echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder && \
  chmod 600 /etc/sudoers.d/builder && \
  mkdir -p /home/builder/sys-config /home/builder/scripts && \
  chown -R builder /home/builder

ADD ./nix-setup.sh ./editline-setup.sh ./lowdown-setup.sh ./nixos-setup.sh /home/builder/scripts/
RUN \
  chmod +x /home/builder/scripts/* && \
  chown -R builder /home/builder && \
  sudo -u builder bash -e -c "cd /home/builder && bash ./scripts/editline-setup.sh"
RUN sudo -u builder bash -e -c "cd /home/builder && bash ./scripts/lowdown-setup.sh"
RUN sudo -u builder bash -e -c "cd /home/builder && bash ./scripts/nix-setup.sh"

ADD default.nix configuration.nix /home/builder/sys-config/
RUN \
  mkdir /sys-root && \
  chown -R builder /nix && \
  sudo -u builder bash -e -c "cd /home/builder && /usr/bin/nixos-setup.sh" && \
  tar -C /sys-root -xf /home/builder/sys-config/result.tar.xz && \
  rm /home/builder/sys-config/result.tar.xz

FROM scratch

WORKDIR /
COPY --from=builder /sys-root/ /

ENTRYPOINT ["/init"]
