+++
title = 'Hack The Box: Starting Point (Meow) - Beating Your First Box!'
date = 2025-03-10T10:00:00+01:00
draft = false
tags = ["htb", "pentesting", "tutorial", "ctf"]
categories = ["Hack The Box", "Tutorials"]
description = "A beginner-friendly walkthrough of the Hack The Box Starting Point Meow machine, setting up your environment and a guide to beat your first box!"
+++

# Hack The Box Starting Point - Meow Walkthrough

Welcome to the first post in my **Hack The Box Starting Point** series! This series will cover the beginner-friendly machines in Hack The Box's Starting Point track, designed to help newcomers learn the basics of penetration testing.

Today, we're tackling **Meow**, a straightforward machine that introduces key concepts like VPN connections, port scanning, and basic service enumeration. This walkthrough includes a guide to setting up your hacking environment to finding your first ever flag!

> **Note**: If you get stuck, refer to the hints in the Hack The Box platform or the [HTB write-up](blob:https://app.hackthebox.com/4bcb624e-6e5d-4f85-9884-3ca95654e8ee) for extra (official) guidance :)

## Setting Up Your Hacking Environment

Before diving into the Meow machine, you need to connect to the Hack The Box lab environment. There are two main ways to do this: using **Pwnbox** or **OpenVPN**. Here's how to set up both.

### Option 1: Connect Using Pwnbox

Pwnbox is a preconfigured, browser-based virtual machine provided by Hack The Box, loaded with all the hacking tools you'll need. It's the recommended option for beginners because it requires minimal setup.

- **Steps to Connect**:
  1. Log in to your Hack The Box account.
  2. Navigate to the **Starting Point** section and select the Meow machine.
  3. Click the **Pwnbox** button to launch it.
  4. Wait for the virtual machine to boot in your browser. You'll get a free 2-hour session with the free tier. This should be all you need.
  5. Once Pwnbox is running, you're ready to start!

### Option 2: Connect Using OpenVPN

If you prefer using your own machine, you can connect to the Hack The Box labs via OpenVPN. This gives you full control over your environment but requires a bit more setup.

- **Steps to Connect**:
  1. Log in to Hack The Box and go to the **Access** section.
  2. Download the VPN configuration file for the Starting Point lab (e.g., `starting_point.ovpn`).
  3. Install OpenVPN on your system:
     - **Linux**: `sudo apt-get install openvpn`
     - **macOS**: `brew install openvpn`
     - **Windows**: Download the OpenVPN client from the official website.
  4. Run the VPN connection:
     ```bash
     sudo openvpn starting_point.ovpn
     ```
  5. Enter your Hack The Box credentials if prompted.
  6. Verify the connection by checking your IP in the Hack The Box dashboard.

This will be better to setup in the future for a couple reasons:
  - You will learn more, and gain a better understanding of tools and your environment.
  - It's ideal if you're building your own custom image (e.g., Parrot OS).

For Meow, Pwnbox is easier since it's a simple box, but try OpenVPN if you want to practice setting up your own environment.

## Meow Walkthrough

The Meow machine is designed to teach you the basics of connecting to a target, scanning for open ports, enumerating services, and gaining access. Let's go through each task step by step.

### Task 1: What does the acronym VM stand for?

This task introduces a fundamental concept in Hack The Box labs.

{{< collapse summary="Click to reveal the answer" >}}
Virtual Machine
{{< /collapse >}}

### Task 2: What tool do we use to interact with the operating system in order to issue commands via the command line, such as the one to start our VPN connection?

Think about the interface you use to type commands on your system.

{{< collapse summary="Click to reveal the answer" >}}
terminal
{{< /collapse >}}

### Task 3: What service do we use to form our VPN connection into HTB labs?

This is the protocol that secures your connection to the Hack The Box network.

{{< collapse summary="Click to reveal the answer" >}}
openvpn
{{< /collapse >}}

### Task 4: What tool do we use to test our connection to the target with an ICMP echo request?

This tool checks if a target is reachable over the network.

{{< collapse summary="Click to reveal the answer" >}}
ping
{{< /collapse >}}

Try testing tis by running `ping <target_ip>` to confirm your VPN connection is working. You'll get the target IP when you spawn the Meow machine.

### Task 5: What is the name of the most common tool for finding open ports on a target?

This tool is a pentester's best friend for discovering what's running on a system.

{{< collapse summary="Click to reveal the answer" >}}
nmap
{{< /collapse >}}

Example: Once you have the target IP, run:

```bash
nmap <target_ip>
```

This will scan for open ports and services.

### Task 6: What service do we identify on port 23/tcp during our scans?

After scanning the target, check which service is running on port 23.

{{< collapse summary="Click to reveal the answer" >}}
telnet
{{< /collapse >}}

Note: Telnet is an old, insecure protocol. Finding it open is a big clue about potential vulnerabilities.

### Task 7: What username is able to log into the target over telnet with a blank password?

Now that you know the service, try connecting to it and testing common credentials.

{{< collapse summary="Click to reveal the answer" >}}
root
{{< /collapse >}}

How to Test:

```bash
telnet <target_ip>
```

At the login prompt, try the username with no password.

### Submit Flag: What is the root flag?

Once you're in, have a dig around for the flag file :)

{{< collapse summary="Click to reveal the answer" >}}
b40abdfe23665f766f9c61ecba8a4c19
{{< /collapse >}}

All done!

## Key Takeaways

The Meow machine is a nice and easy introduction to pentesting, if you have not come from a technical background, it's a great way to ease you into what might feel like an intimidating area of experise. It shows that anyone can learn, and here are some of the concepts we should know more about now:

- **VPN Connections**: Setting up Pwnbox or OpenVPN is essential for accessing Hack The Box labs.
- **Network Scanning**: Tools like ping and nmap help you map out a target.
- **Service Enumeration**: Identifying services (like telnet) reveals potential entry points.
- **Credential Testing**: Simple misconfigurations, like blank passwords, are common in beginner boxes.

This box is all about building confidence with basic tools. I find researching new concepts on the side helps continue to develop my understanding. I' don't always retain information the first time I encounter it, so this usually works for me.

## What's Next?

I'll probably continue this series with more Starting Point machines. The official documentation is available on the platform, however it can be nice to have another perspective sometimes.