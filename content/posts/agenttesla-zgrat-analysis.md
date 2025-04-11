+++
title = "Malware Analysis: AgentTesla and ZGRat"
date = 2024-12-15T23:00:00+00:00
draft = false
tags = ["malware", "AgentTesla", "ZGRat"]
categories = ["Malware", "Threat Intelligence"]
description = "A detailed analysis of AgentTesla and ZGRat malware samples, including behaviour, MITRE ATT&CK mapping, and indicators of compromise"
+++

This post details my analysis of AgentTesla and ZGRat malware samples, examining their behaviour, capabilities, and the indicators of compromise they leave behind.

## Overview

The analysis revealed a sophisticated malware operation using both AgentTesla and ZGRat, with data exfiltration capabilities and persistence mechanisms. The malware authors implemented various techniques to evade detection while harvesting sensitive information from infected systems.

## Configuration Analysis

The configuration analysis revealed SMTP credentials likely used for exfiltrating data:
- SMTP server: mail[.]expertsconsultgh[.]co on port 587
- Associated email addresses suggest the capability to send stolen data to attacker-controlled email addresses

## MITRE ATT&CK Mapping

The dynamic analysis yielded several behavioural characteristics aligned to the following MITRE ATT&CK stages:

**Execution & Persistence:**
- Utilisation of scheduled tasks (T1053) for execution and maintaining persistence

**Privilege Escalation:**
- The same scheduled task technique is used to elevate the malware's privileges

**Credential Access:**
- Discovery of unsecured credentials (T1552)
- Credentials stored in files (T1552.001)

**Discovery:**
- The malware queries the registry (T1012)
- Discovers system information (T1082)
- Enumerates peripheral devices (T1120)

**Collection:**
- Data is collected from the local system (T1005)
- Targets email clients for data theft (T1114)

## Network Activity

The malware engaged in various network activities including:
- DNS queries for reverse DNS PTR records
- HTTP GET requests to Bing services

These requests could be indicative of command-and-control communication or attempts to disguise malicious traffic as legitimate.

## Downloads

Several files were downloaded or accessed, including:
- Preferences and state information for the Microsoft Edge browser
- Various memory dumps ranging from 152 bytes to 7MB

Additionally, the presence of `_PSScriptPolicyTest*.ps1` files suggests that PowerShell was likely used, potentially for:
- Execution policy bypass
- Modifying system preferences
- Other script-related activities

## Process Activity

Multiple suspicious processes were observed, including:
- Execution of malware from the Temp directory
- PowerShell used to modify Defender preferences (defence evasion)
- Creation of scheduled tasks for persistence
- Microsoft Edge processes potentially exploited for surveillance

## Malware Signatures

### AgentTesla

**Type:** Remote Access Tool (RAT)  
**Language:** Written in Visual Basic  
**Capabilities:**
- Keylogger: Records user keystrokes
- Trojan: Misleads users of its true intent
- Stealer: Harvests sensitive data from the infected system
- Spyware: Covertly observes user behaviour and gathers information

AgentTesla has been directly linked with indicators of compromise related to ZGRat, suggesting a possible connection or overlap in tactics.

### ZGRat

**Type:** Remote Access Trojan (RAT)  
**Language:** Written in C#  
**Capabilities:**
- Checks computer location settings, potentially for geofencing
- Reads data files stored by FTP clients (e.g., FileZilla configuration files)
- Targets local email client data
- Accesses user/profile data from web browsers to extract credentials
- Interacts with Microsoft Outlook profiles

**Suspicious Activities:**
- Use of SetThreadContext
- Enumerates physical storage devices and interacts with storage/optical drives
- Checks SCSI registry keys and processor information to detect sandbox environments
- Creates scheduled tasks for persistence or post-infection execution
- Enumerates system info in the registry
- Uses NtCreateUserProcess to block non-Microsoft binaries
- Suspicious use of AdjustPrivilegeToken
- Finds and interacts with the Shell Tray Window
- Uses SendNotifyMessage in a potentially suspicious manner
- Writes to the memory of another process (WriteProcessMemory)
- Specific references to paths used by Outlook

## Indicators of Compromise (IoCs)

Below are the IoCs obtained from the analysis, categorised by type and modified to prevent direct exploitation:

### AgentTesla Related Files:
- C:\Users\Admin\AppData\Local\Microsoft\Edge\User Data\Crashpad\settings.dat
  - SHA256: 4f3db63d7fb486a9af5ae2de005a23040d4edb2067439fff25de8ab41b120035

### ZGRat Related Files:
- C:\Users\Admin\AppData\Local\Microsoft\Edge\User Data\Default\Network Persistent State
  - SHA256: 5dfc321417fc31359f23320ea68014ebfd793c5bbed55f77dab4180bbd4a2026

### Common to Both Malware Families:
- C:\Users\Admin\AppData\Local\Microsoft\Edge\User Data\Default\Preferences
  - SHA256:
    - 3b1c14df5eddd3ccbe04ad76bd16b9094a6686173507d8d229e07329973213e7
    - 1e7273b627e47c6ebcb104f31f519f4899b3c4e9f14413de6c0832abca63ff43
- C:\Users\Admin\AppData\Local\Microsoft\Edge\User Data\Default\Secure Preferences
  - SHA256: e25c91ffeeee88c35da3b596ac742d7d2e5ea4a5d460a12c1885973006ae69dd
- C:\Users\Admin\AppData\Local\Microsoft\Edge\User Data\Local State
  - SHA256: 172794fa65254783ad165d378fe3444fe93378231ca4b8cd46406e08fd48a0d9
- C:\Users\Admin\AppData\Local\Microsoft\Edge\User Data\ShaderCache\GPUCache\data_1
  - SHA256: b1e963d702392fb7224786e7d56d43973e9b9efd1b89c17814d7c558ffc0cdec
- C:\Users\Admin\AppData\Local\Temp__PSScriptPolicyTest_gzucciuv.qjt.ps1
  - SHA256: 96ad1146eb96877eab5942ae0736b82d8b5e2039a80d3d6932665c1a4c87dcf7
- C:\Users\Admin\AppData\Local\Temp\tmp6FCC.tmp
  - SHA256: 5a2a04a9704c64a162a09d74be7b461dac6595e387dd9f05defcd5ada99e1fb9

### Network Signatures:

#### DNS Queries:
- 17[.]160[.]190[.]20[.]in-addr[.]arpa
- 95[.]221[.]229[.]192[.]in-addr[.]arpa
- 208[.]194[.]73[.]20[.]in-addr[.]arpa
- 121[.]252[.]72[.]23[.]in-addr[.]arpa
- 241[.]154[.]82[.]20[.]in-addr[.]arpa
- 39[.]142[.]81[.]104[.]in-addr[.]arpa
- 43[.]58[.]199[.]20[.]in-addr[.]arpa
- 200[.]197[.]79[.]204[.]in-addr[.]arpa
- 2[.]136[.]104[.]51[.]in-addr[.]arpa (noted as multiple queries)
- 26[.]165[.]165[.]52[.]in-addr[.]arpa
- 171[.]39[.]242[.]20[.]in-addr[.]arpa
- 163[.]252[.]72[.]23[.]in-addr[.]arpa
- 88[.]156[.]103[.]20[.]in-addr[.]arpa
- g[.]bing[.]com
- tse1[.]mm[.]bing[.]net

#### HTTP Requests:
- https[:]//g[.]bing[.]com/neg/0?action=...
- https[:]//tse1[.]mm[.]bing[.]net/th?id=...

#### Email Transaction Details:
- SMTP Server: mail[.]expertsconsultgh[.]co
- User: oppong@expertsconsultgh[.]co
- Password: Oppong.2012
- Recipient Address: wisdombig57@gmail[.]com

### Miscellaneous:
- Memory dump files from various processes named like memory/1256-*-memory.dmp
- Scheduled tasks used for execution and persistence named "Updates*"

## Conclusion

Both AgentTesla and ZGRat are sophisticated pieces of malware with capabilities that include stealth, data theft, and persistent access. They focus on evading detection while maintaining a foothold on compromised systems.

> **Disclaimer:** All IoCs have been obfuscated to prevent accidental clicking or execution.