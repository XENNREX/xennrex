# Xennrex Cloud v11.0 - Zero-Touch Client Provisioner

> **One script. One command. Full client provisioning.**

## 🚀 Quick Start

When a new client signs up and pays:

```bash
# 1. SSH into the new server
ssh admin@<server-ip>

# 2. Download and run the installer
wget -q https://raw.githubusercontent.com/XENNREX/xennrex/main/install.sh -O /tmp/install.sh && sudo bash /tmp/install.sh

# 3. Answer the prompts (takes 2 minutes)
# 4. Wait ~30-40 minutes for full setup
# 5. Done! Client gets welcome email automatically
```

## 📋 What Gets Installed

| Component | Purpose |
|-----------|---------|
| **Docker + Compose** | Container runtime |
| **Nextcloud** | Cloud storage & collaboration |
| **MariaDB** | Database |
| **Redis** | Caching |
| **Tailscale** | Secure VPN mesh |
| **Cloudflare Tunnel** | Public HTTPS access |
| **UFW + Fail2ban** | Firewall & brute-force protection |
| **Geo-blocking** | Block high-risk countries |
| **msmtp** | Gmail SMTP relay |
| **Backblaze B2** | Automated daily backups |
| **Healthchecks** | Uptime monitoring |
| **Anti-sleep** | Permanent keep-alive |

## 🔐 Security Features

- ✅ AES-256 encryption at rest
- ✅ TLS 1.3 in transit
- ✅ 2FA enforced for all users
- ✅ Terms of Service enforced before access
- ✅ Self-registration with admin approval
- ✅ Geographic IP blocking (CN, RU, KP, IR, etc.)
- ✅ Daily encrypted backups to Backblaze B2
- ✅ Brute-force protection (fail2ban)
- ✅ Automated security updates (Watchtower)

## 📁 Repo Structure

```
xennrex/                               ← PRIVATE REPO
├── install.sh                          # Master installer (run this)
├── README.md                           # Setup instructions
├── .gitignore                          # Ignore rules
└── web-catalog/
    ├── index.html                      # Animated landing page
    ├── terms-of-service.html           # SaaS Terms of Service
    └── privacy-policy.html             # POPIA Privacy Policy
```

## ⚠️ Important Notes

- **Private repo only** — Never make this repository public
- All infrastructure credentials are hardcoded in `install.sh`
- Client-specific info is collected via interactive prompts
- Tailscale auth key expires **Sep 26, 2026** — generate new one before expiry
- Gmail app password may need rotation periodically

## 📞 Support

- **Email:** info@xennrex.org
- **Phone:** 068 668 8888
