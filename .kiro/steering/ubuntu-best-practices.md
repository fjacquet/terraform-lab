## Ubuntu Server Best Practices

### Overview

Ubuntu Server is a popular Linux distribution for servers, cloud deployments, and containers. It provides a stable, secure, and well-supported platform for running applications and services.

**Core Components:**

- **APT**: Advanced Package Tool for package management
- **Systemd**: System and service manager
- **Netplan**: Network configuration tool
- **UFW**: Uncomplicated Firewall
- **OpenSSH**: Secure remote access
- **Snap**: Universal package manager
- **Cloud-init**: Cloud instance initialization

### System Installation and Initial Setup

**Post-Installation Tasks**

```bash
# Update package lists and upgrade system
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y \
    vim \
    curl \
    wget \
    git \
    htop \
    net-tools \
    build-essential \
    software-properties-common

# Set timezone
sudo timedatectl set-timezone America/New_York

# Configure hostname
sudo hostnamectl set-hostname server01

# Create admin user
sudo adduser admin
sudo usermod -aG sudo admin

# Disable root login
sudo passwd -l root
```
