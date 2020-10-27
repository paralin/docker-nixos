FROM alpine:edge as builder

# Use the install script within alpine linux to bootstrap NixOS.
# nyx nyx nyx nyx nyx!
ADD ./nix-install.sh /usr/bin/nix-install.sh
ADD ./nix-setup.sh /usr/bin/nix-setup.sh
RUN mkdir -m 0755 /nix && \
  chmod +x /usr/bin/nix-install.sh /usr/bin/nix-setup.sh && \
  apk add --update --no-cache \
  alpine-sdk sudo curl bash && \
  adduser -D --home /home/nixbld --shell /bin/bash nixbld && \
  echo "nixbld ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/nixbld && \
  chmod 600 /etc/sudoers.d/nixbld && \
  chown -R nixbld /nix && \
  mkdir -p /home/nixbld/sys-config && \
  sudo -u nixbld bash -c "/usr/bin/nix-install.sh --no-daemon"

# . /home/nix/.nix-profile/etc/profile.d/nix.sh
ADD default.nix configuration.nix /home/nixbld/sys-config/
RUN \
  mkdir /sys-root && \
  chown -R nixbld /home/nixbld && \
  sudo -u nixbld bash -e -c "/usr/bin/nix-setup.sh" && \
  tar -C /sys-root -xf /home/nixbld/sys-config/result.tar.xz && \
  rm /home/nixbld/sys-config/result.tar.xz

FROM scratch

WORKDIR /
COPY --from=builder /sys-root/ /

ENTRYPOINT ["/init"]
