+++
title = 'Pi-hole Wireguard VPN in Azure'
date = 2024-11-19T14:00:00+01:00
draft = false
tags = ["networking", "vpn", "azure", "pi-hole", "wireguard", "privacy"]
categories = ["Azure", "Networking"]
description = "A guide to setting up a Pi-hole VPN with Wireguard on an Azure virtual machine for ad-blocking and privacy."
+++

# Pi-hole Wireguard VPN in Azure

This guide outlines the steps for setting up a Pi-hole VPN with Wireguard on an Azure virtual machine (VM). We will cover creating the VM, configuring Wireguard, and installing Pi-hole.

## Step 1: Azure VM Setup

### Create a New Resource Group

To create a new resource group, run:

```bash
az group create --name rg-phwg-vpn --location uksouth
```

### Create a Virtual Machine

Now, create your virtual machine with the following command:

```bash
az vm create --name vm-phwg --resource-group rg-phwg-vpn --image ubuntu2204 --admin-username ubuntu --public-ip-address vm-phwg-ip --public-ip-address-allocation static --generate-ssh-keys
```

This command will also generate SSH key files, enabling SSH access to your VM.

### Open Port for Wireguard

Next, open port 4400, which will be used for Wireguard:

```bash
az vm open-port --port 4400 --resource-group rg-phwg-vpn --name vm-phwg
```

### Check Public IP

To check your VM's public IP address, use:

```bash
az network public-ip show --resource-group rg-phwg-vpn --name vm-phwg --query '[ipAddress,publicIpAllocationMethod,sku]' --output table
```

## Step 2: Set Up Wireguard

### SSH into the VM

Connect to your VM via SSH using the public IP address from the previous step:

```bash
ssh -i ~/.ssh/id_rsa ubuntu@<your-public-ip>
```

### Update and Install UFW

Update your system and install UFW (Uncomplicated Firewall):

```bash
sudo apt update && sudo apt upgrade && sudo apt install ufw
```

### Configure UFW

Allow SSH and the VPN port through UFW:

```bash
sudo ufw allow 22
sudo ufw allow 4400
sudo ufw enable
```

### Install Wireguard

Use the PiVPN script to install Wireguard:

```bash
curl -L https://install.pivpn.io | bash
```

### Configure DNS Settings

Edit the DNS settings:

```bash
sudo nano /etc/systemd/resolved.conf
```

Uncomment the DNS line and add your preferred DNS servers:

```
DNS=1.1.1.1 9.9.9.9
```

### Symlink the Systemd Resolve File

Run the following commands to symlink the resolve file:

```bash
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl stop systemd-resolved
sudo systemctl start systemd-resolved
```

If you encounter an error like "unable to resolve host", resolve it by editing the hosts file:

```bash
sudo nano /etc/hosts
```

Add the following line:

```
127.0.0.1 vm-phwg
```

### Verify the DNS Settings

You can verify the DNS settings by running:

```bash
dig google.com | grep "SERVER"
```

## Step 3: Configure Wireguard

After installing Wireguard, configure new clients using the pivpn command:

```bash
pivpn -a
pivpn -qr
```

## Step 4: Set Up Pi-hole

### Install Pi-hole

Pull and execute the Pi-hole installation script:

```bash
sudo curl -sSL https://install.pi-hole.net | bash
```

After installation, access the Pi-hole admin interface at `http://<your-server-ip>/admin`.

### Configure UFW for Pi-hole

#### Allow DNS Traffic (Port 53)

To allow DNS traffic from your VPN network, run:

```bash
sudo ufw allow from 10.78.120.1/24 to any port 53
```

#### Allow HTTP Traffic (Port 80)

To access the Pi-hole admin interface, allow HTTP traffic on port 80:

```bash
sudo ufw allow from 10.78.120.1/24 to any port 80
```

With these changes, Pi-hole should be set up and ready to block ads while being accessible through your VPN network.

## Step 5: Resize VM to Save Costs

Resize your VM to a smaller size to save costs:

```bash
az vm resize --resource-group rg-phwg-vpn --name vm-phwg --size Standard_DS3_v2
```

## Step 6: Configure VPN on Windows 11

### Copy Configuration File

Use scp to copy the Wireguard client configuration file from your VM to your local Windows machine:

```bash
scp <username>@<public-ip>:/home/ubuntu/configs/<client>.conf C:\users\<username>\Downloads
```

Replace `<username>` with your VM's username, `<public-ip>` with your VM's public IP address, and `<client>` with the specific client configuration file name.

### Install Wireguard App

#### Download and Install Wireguard

Go to the [Wireguard website](https://www.wireguard.com/install/) and download the Windows app. Install the application on your Windows 11 machine.

#### Import the Configuration File

Open the Wireguard app, click on "Import Tunnel(s)", and select the .conf file you transferred. This will set up the VPN profile in the app.

#### Connect to the VPN

With the configuration imported, click "Activate" to connect to the VPN.

By completing these steps, you should now have a functional Pi-hole VPN configured on your Windows 11 machine.