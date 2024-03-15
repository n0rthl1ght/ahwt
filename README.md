# AHWT - another hardening tool for Windows operating systems.
![image](https://github.com/n0rthl1ght/ahwt/assets/92512883/f60dd952-296c-4574-9129-88e59e66e352)

## Description
Program is a script generator with collection parameters and recommendations from CIS Benchmarks and DoD STIGs with some adjusments.

All parameters placed in databases with the names of the operating systems that are used to. 

Parameters were checked and tested according to official MS documentation and researchers opinion.

Scripts generates in 2 modes - auto and manual

All databases have profiles for each operating system min/med/full which corresponds with Minimum (only level 3 parameters (CIS lvl 2/STIG lvl 3)), Medium (level 2 & 3 parameters (CIS lvl 1 & 2/STIG lvl 2)) and Full (lvl 1-3 parameters).

![image](https://github.com/n0rthl1ght/ahwt/assets/92512883/406eca52-b9d1-44e3-854b-f1e24e037ee6)

For every operating system were made additional profiles that you can generate separate or after generating the general script:
1. Windows XP
   - Windows Firewall (ShieldUp mode has separate confirmation)
2. Windows Vista
   - Windows Firewall (ShieldUp mode has separate confirmation)
   - Windows Defender
3. Windows 7
   - Windows Firewall (ShieldUp mode has separate confirmation)
   - Windows Defender
   - BitLocker
4. Windows 8
   - Windows Firewall (ShieldUp mode has separate confirmation)
   - Windows Defender
   - BitLocker
5. Windows 8.1
   - Windows Firewall (ShieldUp mode has separate confirmation)
   - Windows Defender
   - BitLocker
6. Windows 10
   - Windows Firewall (ShieldUp mode has separate confirmation)
   - Windows Defender
   - BitLocker
   - MS Edge
   - Next Generation Security
7. Windows 11
   - Windows Firewall (ShieldUp mode has separate confirmation)
   - Windows Defender
   - BitLocker
   - MS Edge
   - Next Generation Security

> [!WARNING]
> ShieldUp mode block all incoming connections, including those in the list of allowed apps setting found in either the Windows Settings app or Control Pane

In manual mode you can check every parameter with description. Description will be translated (Google Translate) to system language if you have internet connection.

![image](https://github.com/n0rthl1ght/ahwt/assets/92512883/f7be2112-60d7-44e7-b597-bb5cb690455e)

## Under the hood

Every generated script has command to create a system restore point (if it disabled, script will enable it (not addons)).

Applying parameters contains secedit template and db, auditpol parameters, disabling some services with powershell and parameters from dbs.

All scripts will be ```.bat``` files. I don't like Powershell syntax :)

All additional files like secedit templates and others placed in Templates folder.

> [!NOTE]
> For using EMET for Windows 7 - 8.1 you need to install EMET 5.52

## Usage

1. Download files
2. Start with ```python AHWT.py```
3. Choose OS
   
   ![image](https://github.com/n0rthl1ght/ahwt/assets/92512883/9944050a-6efb-4bb1-a845-eed1859c4604)

4. Enter the name to your script

   ![image](https://github.com/n0rthl1ght/ahwt/assets/92512883/6ef6f64f-d7ff-4c9c-a802-3e988e1ac7ec)

5. Choose mode
   
   ![image](https://github.com/n0rthl1ght/ahwt/assets/92512883/51373b37-c385-40e5-adea-a66be9443935)

6. Choose the level of hardening

   ![image](https://github.com/n0rthl1ght/ahwt/assets/92512883/cf7d3cea-a8e2-4c85-8962-d7ff3fc8209d)

7. Add parameters of additional profiles if you need

   ![image](https://github.com/n0rthl1ght/ahwt/assets/92512883/429dd5a9-2388-4d16-a4e6-fc35f71a50e6)

8. Get additional files from Templates and place it with generated script

    ![image](https://github.com/n0rthl1ght/ahwt/assets/92512883/531edd63-58b0-489f-9a87-12ed33c08e81) -> ![image](https://github.com/n0rthl1ght/ahwt/assets/92512883/3cbdaf57-74c3-4236-9abf-cb9feaf837f1) -> ![image](https://github.com/n0rthl1ght/ahwt/assets/92512883/b1c0e6dc-6942-4bc4-b779-1988c6824f16)

9. Run it on targeted PC

> [!CAUTION]
> Before applying scripts on real PC test you configurations on VMs

### Feel free to post issues

## Roadmap
- [ ] Enrich DBs with new parameters for every OS
- [ ] Optimize code (for now its shitty code, i know :))
- [ ] Add support for third party software, Server editions and everything that relates to Windows operating systems
- [ ] Anything else...

Made with desire to help all Blue Teamers ❤️
