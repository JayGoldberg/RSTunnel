# RSTunnel
A continuation of Reliable SSH Tunnel, **without** needing the `autossh` binary.

RSTunnel (Reliable SSH Tunnel) is a set of pure shell scripts (`/bin/sh` compatible) that maintain a secure tunnel from a client to a server.

## Why would you need a reverse tunnel?
RSTunnel is useful for situations where you want to have SSH access to administer remote endpoints that are behind NAT. For example, if you deploy IP cameras or WiFi Access Points to customer premises and need the ability to always connect back to them through an intermediate host without setting up port forwarding rules at your client site (or you do not have admin access to the firewall to do so).

## Why a new project?
`autossh` will probably meet your needs just fine. However, it requires you to compile a binary for non-standard platforms (ARM, MIPS). Things like WiFi access points, IP cameras, etc. Getting a cross compiling toolchain is non-trivial.

The goal of this continuation of RSTunnel is to require nothing more than a shell, even a simplistic one like `ash`, and also, compatibility with the `dropbear` SSH client.
