+++
title = 'Phobos Ransomware Impersonating Vx-Underground'
date = 2025-01-06T12:00:00-00:00
draft = false
tags = ["ransomware", "malware", "phobos", "vx-underground"]
categories = ["Malware", "Threat Intelligence"]
+++

## Introduction

Phobos ransomware has been previously observed impersonating the well-known malware research community Vx-Underground. Initial access methods for Phobos are varied, but it has been known for exploiting software vulnerabilities, launching phishing campaigns to spread malicious payloads, and accessing hosts through external services such as brute forcing RDP.

Despite its significant operational impact, with Phobos accounting for a notable 4% of all submissions to the ID Ransomware service in 2023, it hasn't achieved the notoriety of other Ransomware-as-a-Service (RaaS) operations like Lockbit or REvil. This discrepancy points to the evolving and increasingly accessible nature of RaaS platforms, allowing less technically skilled attackers to launch ransomware campaigns.

![Vx-Underground Logo](/images/vxunderground/vxundergound_logo.png)

## Approach

To understand the ransomware's behaviour in a real-world setting, we conducted analysis using a cloud-based sandbox, Recorded Future. This approach allowed us to mimic a Security Operations Center (SOC) environment, facilitating fast-paced, dynamic, and static analysis of the malware.

## Sample Information

- **Malware Family**: Phobos
- **Target File Name**: 763b04ef2d0954c7ecf394249665bcd71eeafebc3a66a27b010f558fd59dbdeb.zip 
- **File Size**: 48KB
- **MD5**: 5f3689f795c7111c259d76bd19c509d3 
- **SHA-1**: f40c93f931979959e9ca4236d3b3c3e6b4342982
- **SHA-256**: 35c01c9613c4f96a634ecebac702bdef8e1e194b96c3fc2d0b1bd997c2d8c98c
- **SSDEEP**: 1536:BNvqk8FQgnN2VSPzZ7QtQls0GjoBbFZrt6Jy:B1b8FQgN1PzZ7QtQls0GsBbzrtn

## Vx-Underground Impersonation

The following screenshots were captured from the Windows 7 host, displaying multiple instances of 'vx-underground' .hta (HTML application) files. The process mshta.exe was used to display ransom notes in various locations, falsely indicating Vx-Underground's involvement.

![Vx-Underground HTA Ransom Note](/images/vxunderground/vx-undergroundhta.webp)

Notably, we can see three highlighted strings: the official support email for Vx-Underground, their Twitter username, along with a unique victim ID. Also identified is the common ransomware tactic of offering to decrypt five files for free to prove to the victim that the attackers can decrypt the files, an attempt to establish "trust" and therefore increase the chance of payment.

![Encrypted Documents](/images/vxunderground/encrypted_docs.png)

Ironically, the "Buy Black Mass Volume I.txt" ransomware note, which is also the name of Vx-Underground's research and malware book, states that the decryption password is not "infected" — the password used across Vx-Underground's entire malware repository (lol).

![Buy Black Mass Volume I](/images/vxunderground/Buy_Black_Mass_Volume_I.png)

## Key Findings

In our analysis of the Phobos ransomware variant, several key findings emerged:

- **Execution from Temp Directory**: The ransomware initiated its attack from the `AppData\Local\Temp` directory, a common launching point for malware due to its lower security scrutiny, but also the staging area for the Recorded Future sandbox.

- **System Security Disabling**: Phobos used `netsh.exe` commands to disable Windows Firewall, creating a more vulnerable environment for further malicious activities.

- **Backup and Recovery Disruption**: The ransomware strategically employed `vssadmin.exe` and `WMIC.exe` to delete Volume Shadow Copies, hindering recovery efforts by eliminating system restore points and backups.

- **No Direct Communication with C2 Servers**: Interestingly, the variant showed no network traffic, indicating it could operate independently without direct command and control (C2) communication. This characteristic makes it potentially more robust in isolated environments.

- **Registry and Boot Configuration Modifications**: Using `bcdedit.exe`, Phobos altered the boot configuration to prevent automatic recovery features, further complicating the victim's ability to restore their system.

- **Unique File Encryption**: The encryption process appended a `.VXUG` file extension along with the victim ID.

## Suspicious Windows API Functions

In the Phobos ransomware analysis, two Windows API calls typically used for legitimate purposes were identified as being exploited for malicious activities:

- **AdjustTokenPrivilege**: Manages permissions in a process token but was repurposed to escalate the ransomware's process privileges, enabling it to execute actions that require higher access levels.

- **SetWindowsHookEx**: Installs a hook procedure to monitor system events such as keystrokes or mouse inputs. This function was hijacked to spy on user inputs, potentially for keylogging or input capture, indicating spyware capabilities.

## Mapping to MITRE ATT&CK

In mapping the Phobos ransomware variant to the MITRE ATT&CK framework, the analysis revealed several key TTPs (Tactics, Techniques, and Procedures) utilised by the malware:

- **Execution**: Relies on user execution, often through a phishing attachment (T1204.002).

- **Persistence**: Achieved by creating or modifying system-level processes and registry keys to ensure the malware executes on system startup or at scheduled intervals. Netsh is used to disable firewall services (T1543.003, T1547.001).

- **Privilege Escalation**: Involves modifying system processes or registry keys to run with elevated privileges (T1543.003, T1547.001).

- **Defense Evasion**: The malware deletes shadow copies and modifies registry and kernel settings to avoid detection, and clears audit logs to cover its tracks (T1070.004, T1112).

- **Credential Access**: Targets stored browser data and searches for insecurely stored credentials (T1555.001, T1005).

- **Discovery**: Collects information about the host, such as the operating system and hardware details, to scope out future attacks (T1082).

- **Collection**: Similar to credential access, it reads profile data from web browsers and searches local and remote file systems (T1005).

- **Impact**: Encrypts files on local and remote drives, denying access to backups and recovery options, primarily using volume shadow service deletion and modifying boot configuration data (T1486, T1490).

## Indicators of Compromise (IoC)

Below are the IoCs obtained from the analysis, categorised by type and modified to prevent direct exploitation. These files are likely used for various purposes such as executing commands, encrypting data, or enforcing persistence mechanisms.

### Files

- `C:\Users\Admin\AppData\Local\Temp\763b04ef2d0954c7ecf394249665bcd71eeafebc3a66a27b010f558fd59dbdeb.exe`
  - PID: 1276, 2128
  
- `C:\Windows\system32\cmd.exe`
  - PID: 628, 2376, 1640
  
- `C:\Windows\system32\vssadmin.exe`
  - Command: `vssadmin delete shadows /all /quiet`
  - PID: 2660, 1488
  
- `C:\Windows\System32\Wbem\WMIC.exe`
  - Command: `wmic shadowcopy delete`
  - PID: 2328, 1616
  
- `C:\Windows\system32\bcdedit.exe`
  - Commands: `bcdedit /set {default} bootstatuspolicy ignoreallfailures`, `bcdedit /set {default} recoveryenabled no`
  - PID: 2592, 472, 2180, 328
  
- `C:\Windows\system32\netsh.exe`
  - Commands: `netsh advfirewall set currentprofile state off`, `netsh firewall set opmode mode=disable`
  - PID: 2720, 2964
  
- `C:\Windows\SysWOW64\mshta.exe`
  - Commands: `mshta.exe` execution with various HTA files
  - PID: 2972, 692, 3004, 2968
  
- `C:\Windows\system32\vssvc.exe`
  - PID: 2688, 3036
  
- `C:\Windows\explorer.exe`
  - PID: 1572

### Malware Config

- `C:\Buy Black Mass Volume II.hta`
  - Ransom Note: HTML formatted ransom note with instructions and contact information.

### Emails

- staff@vx-underground[.]org

### URLs

- hxxp://www[.]w3[.]org/TR/html4/strict.dtd 
- hxxps://bazaar[.]abuse[.]ch/browse/ 
- hxxps://malshare[.]com/

> **Disclaimer:** All IoCs have been obfuscated to prevent accidental clicking or execution.