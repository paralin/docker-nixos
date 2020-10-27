FROM alpine:edge as builder

RUN \
  echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk add --update --no-cache \
  alpine-sdk sudo curl bash git autoconf automake sqlite-dev curl-dev xz-dev bison flex \
  libtool autoconf-archive boost-dev openssl-dev bzip2-dev libedit-dev libseccomp-dev nix

# Use the install script within alpine linux to bootstrap NixOS.
# nyx nyx nyx nyx nyx!
RUN \
  adduser -D --home /home/builder --shell /bin/bash --ingroup nixbld builder && \
  echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder && \
  chmod 600 /etc/sudoers.d/builder && \
  mkdir -p /home/builder/sys-config && \
  chown -R builder /nix /home/builder

ADD default.nix configuration.nix /home/builder/sys-config/
ADD ./nix-setup.sh /usr/bin/nix-setup.sh
RUN \
  chmod +x /usr/bin/nix-setup.sh && \
  mkdir /sys-root && \
  chown -R builder /home/builder && \
  sudo -u builder bash -e -c "/usr/bin/nix-setup.sh" && \
  tar -C /sys-root -xf /home/builder/sys-config/result.tar.xz && \
  rm /home/builder/sys-config/result.tar.xz

FROM scratch

WORKDIR /
COPY --from=builder /sys-root/ /

ENTRYPOINT ["/init"]
