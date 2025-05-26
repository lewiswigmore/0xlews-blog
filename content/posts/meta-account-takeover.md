+++
title = "Meta Account Takeover: The ig.me Phishing Technique"
date = 2025-05-26T23:00:00+00:00
draft = false
tags = ["phishing", "meta", "instagram", "facebook", "security"]
categories = ["Attacks", "Social Media"]
description = "A breakdown of a targeted phishing attack on a Meta account using ig.me links, the role of MFA, and why Meta’s account system can be a security challenge."
+++

# Meta Account Takeover: The ig.me Phishing Technique

On 26 May 2025, a targeted phishing attack compromised a user’s Meta accounts, leveraging Instagram’s "ig.me" link shortener to steal accounts and gain unauthorised access. The incident exposed the complications of Meta’s account system and again reinforces the need for multi-factor authentication (MFA). This is a brief (hopefully) look at how the attack unfolded, why it still works, and what we can learn from it.

## What Happened?

The target, a user with a personal and business Instagram account, received a phishing message at 09:15. The message came from a verified Instagram business account, in the same small business industry, requesting a vote in a competition via an "ig.me" SMS link. The user was asked to copy and paste the link back via DM, a tactic designed to steal credentials via password reset links.

Later that day, an unusual sign-in alert flagged unauthorised access to the business Instagram account. The attacker reset the password, added their email ("stellamoana236[@]gmail[.]com"), and linked the Instagram account to a fraudulent Facebook page mimicking the user’s profile, using their name and a replaced profile picture. However, the attacker failed to log out all other sessions, an option available in the Meta account settings, allowing the user’s active session to remain logged in alongside the attacker’s session.

The user acted quickly, and reset the password on all accounts (personal and business Instagram and Facebook accounts) and enabled MFA using the Microsoft Authenticator app. Recovery codes were stored as a backup. During this time, the attacker linked the compromised Instagram account to a fraudulent Facebook page mimicking the user’s profile, using the user’s full name and replacing the profile picture to confuse them. However, the user’s active session allowed visibility into this fraudulent page.

Later, at 22:23, the attacker sent a fake Instagram support message via WhatsApp (+44 7456 310347), a last-ditch phishing attempt claiming the account was hacked and urging the user to take action to secure it. This was a desperate phishing attempt to regain control, hoping the user would panic and provide further credentials. Of course, the user did not.

After a back-and-forth of credential rotation, the user successfully secured all their accounts under a single Meta account with MFA enforced. This action inadvertently granted the user control over the fraudulent Facebook page created by the attacker. The user was able to access the attacker’s account, revealing forensic evidence, including login history dating back to November 2024 and personal identifiable information (PII) of previous victims, such as email addresses, phone numbers, and delivery addresses. The user then reported and deleted the attacker’s profile, also removing the fraudulent email and phone number from their accounts.

## The ig.me Phishing Method

The "ig.me" domain, owned by Instagram, is a legitimate link shortener used for profile links and password resets. Attackers exploit its authenticity by crafting phishing messages that appear official, often mimicking Instagram support or verified accounts. In this case, the "ig.me" link tricked the user into sharing a reset link, granting the attacker access.

This method remains effective because:
- It leverages trust in a familiar domain, unlike obviously suspicious URLs.
- Verified accounts, like the attacker's add credibility, exploiting social engineering.
- Urgent requests, such as voting for a business, prompt users to act without verifying.

## Why the Attack Worked

The attacker succeeded initially due to several factors:
- No MFA The absence of multi-factor authentication allowed the attacker to reset the password using the phished link.
- The user’s accounts used legacy independent logins, but Meta’s push to integrate Instagram and Facebook under a single login can confuse users. The attacker exploited this by linking the compromised Instagram account to a fraudulent Facebook page.
- The verified account and "ig.me" link appeared legitimate, lowering the user’s guard.
- The phishing message came from a verified small business account with a legitimate history and mutual followers, adding credibility. Attackers likely pivot between such accounts, rinse-and-repeating their strategy to exploit trust within industry.

### Confusion with Meta's Account Center

Meta’s Accounts Center, while intended to ease account management, can confuse users, especially those familiar with legacy independent logins. The user’s accounts were initially separate, making the sudden linking of their Instagram to a fraudulent Facebook page disorienting. Users accustomed to separate logins may not anticipate cross-platform risks or know how to secure linked profiles, increasing phishing vulnerabilities.

## Attacker’s Methods and Mistakes

The attacker’s strategy involved:

- Phishing via ig.me: Using a verified account to send a deceptive "ig.me" link, exploiting its legitimacy.
- Account Linking: Linking the compromised Instagram account to a fraudulent Facebook page to impersonate the user, causing further confusion.
- Credential Rotation: Resetting passwords and adding their email and phone number to maintain control.


## Attacker’s Login History

The user’s control over the fraudulent Facebook page revealed the attacker’s login history, dating back to November 2024, across multiple devices and locations.

{{< collapse summary="View Attacker’s Login History" >}}
| Date        | Device            | IP Address         | Location                     | ISP                     |
|-------------|-------------------|--------------------|------------------------------|-------------------------|
| 19 Dec 2024 | iPhone 14 Pro Max | 144.126.205.200    | London, UK                   | DigitalOcean, LLC       |
| 18 Jan 2025 | iPhone 12 Pro Max | 84.247.43.135      | Bucharest, Romania           | Orange Romania S.A.     |
| 22 Jan 2025 | iPhone 12 Pro Max | 84.247.42.20       | Bucharest, Romania           | Orange Romania S.A.     |
| 22 Jan 2025 | iPhone 12 Pro Max | 84.247.47.20       | Bucharest, Romania           | Orange Romania S.A.     |
| 22 Jan 2025 | iPhone 12 Pro Max | 84.247.47.238      | Bucharest, Romania           | Orange Romania S.A.     |
| 5 Mar 2025  | iPhone 12 Pro Max | 102.90.100.237     | Onitsha, Nigeria             | MTN Nigeria             |
| 12 Mar 2025 | iPhone 12 Pro Max | 185.91.122.68      | London, UK                   | Overplay, Inc           |
| 23 Mar 2025 | iPhone 12 Pro Max | 197.210.85.76      | Lagos, Nigeria               | MTN Nigeria             |
| 24 Mar 2025 | iPhone 14 Pro Max | 185.105.105.198    | Altavilla Silentina, Italy   | Convergenze S.p.A.      |

The varied locations and ISPs suggest the attacker used proxies or compromised devices to obscure their identity, a common tactic in phishing campaigns.
{{< /collapse >}}

The attacker’s account also contained data on previous victims, including emails, phone numbers, and addresses in locations like Liverpool and Shepperton, UK. The fraudulent email "stellamoana236[@]gmail[.]com" was reported to Google.

## Forensic Findings

The user’s control over the attacker’s Facebook page revealed:

- Login History: Activity from November 2024 to March 2025 across multiple countries, indicating a prolonged campaign.
- Victim PII: Emails, phone numbers, and addresses from prior victims.
- Fraudulent Page: A duplicated Facebook page mimicking the user’s profile, used to confuse followers.

## Importance of MFA

Multi-factor authentication (MFA) adds a second verification step, such as a code from an app, (e.g., a code from an authenticator app) beyond a password. Without MFA, the attacker easily reset the user’s password using the phished "ig.me" link.

Once the attacker obtained the reset link, they changed the password and added their email. However, their failure to log out all sessions allowed the user to stay logged in, reset credentials, and enable MFA using Microsoft Authenticator. This prevented further persistence, even after the attacker added their email.

## How to Protect Yourself

Here are some useful steps to secure your Meta account and avoid similar attacks.

{{< collapse summary="Steps to Secure Your Accounts" >}}
1. **Enable MFA**:
   - Go to Instagram Settings > Security > Two-Factor Authentication.
   - Use an authenticator app (e.g., Microsoft Authenticator).
   - Store recovery codes securely.

2. **Use Strong Passwords**:
   - Create passwords with at least 12 characters, mixing letters, numbers, and symbols.
   - Avoid reuse across platforms; use a password manager.

3. **Verify Links**:
   - Avoid clicking unsolicited links, even from "ig.me."
   - Check URLs for "https://" and official domains.
   - Contact senders offline to confirm legitimacy.

4. **Monitor Activity**:
   - Check "Where you’re logged in" in Meta Accounts Center.
   - Log out unrecognised devices immediately.

5. **Report Phishing**:
   - Forward phishing emails to phish@instagram.com.

6. **Understand Meta’s Accounts Center**:
   - Unify accounts under a single login with MFA enabled.
   - Review linked accounts and revoke suspicious access.
{{< /collapse >}}

## Final Thoughts

This incident shows the persistent threats of phishing on platforms like Instagram, where trusted, domains like "ig.me" are misused. The attacker’s initial success was due to the lack of MFA and the user’s unfamiliarity with Meta’s account system. However, a quick response, enabling MFA and securing their accounts actually exposed the attacker.

Phishing remains effective because it exploits human trust. MFA, strong passwords, and user awareness are essential. Meta needs to better educate users about its Accounts Center to reduce confusion. If you’re on Instagram or Facebook, check your Meta security settings now - don't wait for an attack to remind you.