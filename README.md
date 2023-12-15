# **AHWT - Another Hardening Windows Template**



Just another hardening script based on CIS and DoD recommendations (STIGs).

## ***This prototypes applied in working environment and working fine.***

I created only XP and Win10 versions for now.

Configuring goes through secedit, auditpol and reg add. Nothing more.

To check changes you can use [AuditTAP](https://github.com/fbprogmbh/Audit-Test-Automation)

**10**
- "Isolated" variant of configuration. Nothing special :)

**laptop_10**
- Configuration for laptops like "10" variant. No RDP, no saving passwords.

**laptop_10_sp**
- Same as previous configuration, but with support of RDP and user can save passwords in system.

### **Roadmap:**
- [ ] Add more security changes according with AuditTAP reports and other best practices
- [ ] Add support for Windows Vista/7/8/8.1/11
- [ ] Move all code to Python
- [ ] Make GUI for scripts like choose what level of security you want
- [ ] Other things to make your and mine experience better
