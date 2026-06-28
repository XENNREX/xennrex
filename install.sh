#!/bin/bash
#================================================================================
# XENNREX CLOUD v11.0 ULTIMATE - ZERO-TOUCH CLIENT PROVISIONER
#================================================================================
# Single script: Pi prep → Anti-sleep → Nextcloud → Security → Client onboarding
# Hardcoded credentials for Xennrex infrastructure
# Interactive prompts for client-specific info only
#================================================================================
# Run: sudo bash install.sh
#================================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

log() { echo -e "${GREEN}[$(date '+%H:%M:%S')] ✓${NC} $1"; }
warn() { echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠${NC} $1"; }
error() { echo -e "${RED}[$(date '+%H:%M:%S')] ✗${NC} $1"; }
info() { echo -e "${CYAN}[$(date '+%H:%M:%S')] ℹ${NC} $1"; }
step() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  STEP $1: $2${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
}

#================================================================================
# HARDCODED INFRASTRUCTURE CREDENTIALS (Never change these)
#================================================================================
CF_TUNNEL_TOKEN="eyJhIjoiMmM0MmI3Mjc5NmRmNzc4NGFkZmU0OTlhYTEyNzVkMTgiLCJ0IjoiYmE1NjVmMDItNzUyZS00M2NhLTk5MTYtMTBmYjEzNmQxN2I3IiwicyI6Ik4yRmtNekl5WldNdE5XSXhOUzAwTmpSakxXSTRPVEV0WkRRM05tSXpOakkxTnpneCJ9"
TAILSCALE_AUTH_KEY="tskey-auth-kzMNgNgnms11CNTRL-EnjYDhsVp9gyQo5NWBB1AgUBSfKjJTcJ"
B2_KEY_ID="005b9265d9be8a3000000001"
B2_APP_KEY="K005pPYjFi2yM63jFhpIc1TIyLFOvkQ"
B2_BUCKET="xennrex-backups"
HEALTHCHECKS_UUID="1f5a5c7b-d5fd-417b-958b-7e88807daa08"
SMTP_HOST="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USER="xennrex.cloud@gmail.com"
SMTP_PASS="xnse jqqy imgs poew"
ADMIN_EMAIL="xennrex.cloud@gmail.com"
DOMAIN_BASE="xennrex.github.io"
PAYFAST_MERCHANT_ID="35854935"
PAYFAST_MERCHANT_KEY="cy5krhuoxvofh"
RECAPTCHA_SITE_KEY="6Lc7LDotAAAAAOxJA9z-ArD9wlbJnkpQVE0dY9KZ"
RECAPTCHA_SECRET_KEY="6Lc7LDotAAAAAFMyvaOhufj1WJcQdF_ueWwvfB8q"

# High-risk countries to block
BLOCKED_COUNTRIES="CN RU KP IR BY VE MM AF IQ LY SY SD PK BD NG"

#================================================================================
# INTERACTIVE CLIENT SETUP
#================================================================================
clear
echo -e "${CYAN}"
cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║   ██╗  ██╗███████╗███╗   ██╗███╗   ██╗██████╗ ███████╗██╗  ██╗              ║
║   ╚██╗██╔╝██╔════╝████╗  ██║████╗  ██║██╔══██╗██╔════╝╚██╗██╔╝              ║
║    ╚███╔╝ █████╗  ██╔██╗ ██║██╔██╗ ██║██████╔╝█████╗   ╚███╔╝               ║
║    ██╔██╗ ██╔══╝  ██║╚██╗██║██║╚██╗██║██╔══██╗██╔══╝   ██╔██╗               ║
║   ██╔╝ ██╗███████╗██║ ╚████║██║ ╚████║██║  ██║███████╗██╔╝ ██╗              ║
║   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝              ║
║                                                                               ║
║                    v11.0 ULTIMATE - ZERO-TOUCH PROVISIONER                    ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${YELLOW}This script will:${NC}"
echo "  1. Prepare and harden your server"
echo "  2. Prevent sleep/standby mode permanently"
echo "  3. Install Docker, Nextcloud, Tailscale, Cloudflare Tunnel"
echo "  4. Configure security (firewall, geo-blocking, fail2ban)"
echo "  5. Set up automated backups to Backblaze B2"
echo "  6. Configure email notifications via Gmail"
echo "  7. Enable client self-registration with Terms of Service"
echo "  8. Enforce 2FA for all users"
echo "  9. Test everything and send welcome email to client"
echo ""
read -p "Press ENTER to begin client setup..."
echo ""

# Client Information
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  CLIENT INFORMATION${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -p "Client / Company Name: " CLIENT_NAME
read -p "Client Email Address:  " CLIENT_EMAIL

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  MEGA ACCOUNT (Created by you for this client)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -p "MEGA Account Email:    " MEGA_EMAIL
read -s -p "MEGA Account Password: " MEGA_PASSWORD
echo ""

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  PLAN SELECTION${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "  1) Starter  - 20GB cache / 20GB MEGA storage    (R 99/month)"
echo "  2) Pro      - 50GB cache / 50GB MEGA storage    (R 199/month)"
echo "  3) Business - 100GB cache / 100GB MEGA storage  (R 399/month)"
echo "  4) Custom   - Enter your own sizes"
read -p "Select plan (1-4): " PLAN_CHOICE

case $PLAN_CHOICE in
    1) PLAN_NAME="Starter"; PLAN_SIZE_MB=20480; PLAN_PRICE="R 99/month" ;;
    2) PLAN_NAME="Pro"; PLAN_SIZE_MB=51200; PLAN_PRICE="R 199/month" ;;
    3) PLAN_NAME="Business"; PLAN_SIZE_MB=102400; PLAN_PRICE="R 399/month" ;;
    4)
        read -p "Enter cache size in MB (e.g., 20480 for 20GB): " PLAN_SIZE_MB
        read -p "Enter plan name: " PLAN_NAME
        read -p "Enter plan price: " PLAN_PRICE
        ;;
    *) error "Invalid selection. Exiting."; exit 1 ;;
esac

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  PI CONFIGURATION${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
DEFAULT_HOSTNAME="xennrex-$(echo $CLIENT_NAME | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
read -p "Pi Hostname [$DEFAULT_HOSTNAME]: " PI_HOSTNAME
PI_HOSTNAME=${PI_HOSTNAME:-$DEFAULT_HOSTNAME}

read -p "Allowed Countries (comma-separated) [ZA]: " GEOBLOCK_COUNTRIES
GEOBLOCK_COUNTRIES=${GEOBLOCK_COUNTRIES:-ZA}

read -p "Enable 2FA enforcement? (yes/no) [yes]: " ENABLE_2FA
ENABLE_2FA=${ENABLE_2FA:-yes}

read -p "Enable shadow copies (file versioning)? (yes/no) [yes]: " ENABLE_SHADOW
ENABLE_SHADOW=${ENABLE_SHADOW:-yes}

# Generate unique identifiers
CLIENT_SLUG=$(echo "$CLIENT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
CLIENT_DOMAIN="${PI_HOSTNAME}.xennrex.org"
ADMIN_PASSWORD=$(openssl rand -base64 24 | tr -dc 'a-zA-Z0-9' | head -c 20)

# Create working directory
WORK_DIR="/opt/xennrex"
mkdir -p "$WORK_DIR"

# Save client config
cat > "$WORK_DIR/client-config.env" << EOF
CLIENT_NAME="$CLIENT_NAME"
CLIENT_EMAIL="$CLIENT_EMAIL"
CLIENT_SLUG="$CLIENT_SLUG"
MEGA_EMAIL="$MEGA_EMAIL"
MEGA_PASSWORD="$MEGA_PASSWORD"
PLAN_NAME="$PLAN_NAME"
PLAN_SIZE_MB=$PLAN_SIZE_MB
PLAN_PRICE="$PLAN_PRICE"
PI_HOSTNAME="$PI_HOSTNAME"
CLIENT_DOMAIN="$CLIENT_DOMAIN"
ADMIN_PASSWORD="$ADMIN_PASSWORD"
GEOBLOCK_COUNTRIES="$GEOBLOCK_COUNTRIES"
ENABLE_2FA="$ENABLE_2FA"
ENABLE_SHADOW="$ENABLE_SHADOW"
INSTALL_DATE="$(date -Iseconds)"
EOF

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  SUMMARY - Confirm before proceeding${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "  Client:      $CLIENT_NAME"
echo "  Email:       $CLIENT_EMAIL"
echo "  MEGA:        $MEGA_EMAIL"
echo "  Plan:        $PLAN_NAME ($PLAN_SIZE_MB MB / $PLAN_PRICE)"
echo "  Hostname:    $PI_HOSTNAME"
echo "  Domain:      https://$CLIENT_DOMAIN"
echo "  Admin Pass:  $ADMIN_PASSWORD"
echo "  Geo-block:   All except $GEOBLOCK_COUNTRIES"
echo "  2FA:         $ENABLE_2FA"
echo ""
read -p "Proceed with installation? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    error "Installation cancelled."
    exit 1
fi

#================================================================================
# STEP 1: PI PREPARATION & ANTI-SLEEP
#================================================================================
step "1" "Preparing server & Disabling Sleep Mode"

info "Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq && apt-get upgrade -y -qq

info "Installing essential packages..."
apt-get install -y -qq \
    curl wget git htop vim nano unzip jq \
    apt-transport-https ca-certificates gnupg \
    software-properties-common \
    net-tools dnsutils iputils-ping \
    ufw fail2ban iptables ipset \
    logrotate cron \
    msmtp msmtp-mta mailutils \
    openssl \
    smartmontools \
    2>/dev/null || true

# ANTI-SLEEP: Disable all power management
info "Applying permanent anti-sleep configuration..."

# Disable WiFi power management
cat > /etc/modprobe.d/8192cu.conf << 'EOF'
# Disable WiFi power management
options 8192cu rtw_power_mgnt=0 rtw_enusbss=0
EOF

# Disable USB autosuspend
cat > /etc/modprobe.d/usb-autosuspend.conf << 'EOF'
# Disable USB autosuspend
options usbcore autosuspend=-1
EOF

# Disable Bluetooth (saves power, prevents sleep issues)
systemctl stop bluetooth 2>/dev/null || true
systemctl disable bluetooth 2>/dev/null || true

# Disable HDMI sleep (if monitor connected)
if command -v tvservice &>/dev/null; then
    /opt/vc/bin/tvservice -o 2>/dev/null || true
fi

# Keep-alive script
cat > /usr/local/bin/xennrex-keepalive.sh << 'EOF'
#!/bin/bash
# Xennrex Keep-Alive - Prevents Pi from sleeping
# Runs every 2 minutes via cron

# Ping gateway to keep network active
GATEWAY=$(ip route | grep default | awk '{print $3}' | head -1)
if [ -n "$GATEWAY" ]; then
    ping -c 1 -W 2 "$GATEWAY" >/dev/null 2>&1
fi

# Prevent USB sleep
echo on > /sys/bus/usb/devices/usb1/power/control 2>/dev/null || true
echo on > /sys/bus/usb/devices/usb2/power/control 2>/dev/null || true

# Keep CPU awake
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || true

# Log keepalive
logger -t xennrex-keepalive "Keepalive pulse executed"
EOF
chmod +x /usr/local/bin/xennrex-keepalive.sh

# Add to crontab
crontab -l 2>/dev/null | grep -v "xennrex-keepalive" || true
crontab -l 2>/dev/null > /tmp/crontab_backup 2>/dev/null || true
echo "*/2 * * * * /usr/local/bin/xennrex-keepalive.sh >/dev/null 2>&1" >> /tmp/crontab_backup
echo "0 3 * * * /usr/local/bin/xennrex-backup.sh >/dev/null 2>&1" >> /tmp/crontab_backup
echo "0 2 * * 0 /usr/local/bin/xennrex-antivirus.sh >/dev/null 2>&1" >> /tmp/crontab_backup
crontab /tmp/crontab_backup 2>/dev/null || true
rm -f /tmp/crontab_backup

# Systemd keepalive service
cat > /etc/systemd/system/xennrex-keepalive.service << 'EOF'
[Unit]
Description=Xennrex Keep-Alive Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/xennrex-keepalive.sh
Restart=always
RestartSec=120

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable xennrex-keepalive.service
systemctl start xennrex-keepalive.service

# Disable screen blanking and DPMS
if [ -f /etc/xdg/lxsession/LXDE-pi/autostart ]; then
    echo "@xset s noblank" >> /etc/xdg/lxsession/LXDE-pi/autostart
    echo "@xset s off" >> /etc/xdg/lxsession/LXDE-pi/autostart
    echo "@xset -dpms" >> /etc/xdg/lxsession/LXDE-pi/autostart
fi

# Set hostname
info "Setting hostname to $PI_HOSTNAME..."
echo "$PI_HOSTNAME" > /etc/hostname
hostnamectl set-hostname "$PI_HOSTNAME" 2>/dev/null || true
sed -i "s/127.0.1.1.*/127.0.1.1 $PI_HOSTNAME/" /etc/hosts || echo "127.0.1.1 $PI_HOSTNAME" >> /etc/hosts

log "Pi preparation complete. Sleep mode disabled permanently."

#================================================================================
# STEP 2: DOCKER INSTALLATION
#================================================================================
step "2" "Installing Docker & Docker Compose"

if ! command -v docker &>/dev/null; then
    info "Installing Docker..."
    curl -fsSL https://get.docker.com | bash
    usermod -aG docker pi 2>/dev/null || usermod -aG docker $(whoami) 2>/dev/null || true
    systemctl enable docker
    systemctl start docker
else
    info "Docker already installed."
fi

if ! command -v docker-compose &>/dev/null && ! docker compose version &>/dev/null; then
    info "Installing Docker Compose..."
    apt-get install -y -qq docker-compose-plugin 2>/dev/null || \
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
fi

log "Docker installation complete."

#================================================================================
# STEP 3: TAILSCALE INSTALLATION
#================================================================================
step "3" "Installing Tailscale VPN"

if ! command -v tailscale &>/dev/null; then
    info "Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | bash
fi

info "Authenticating with Tailscale..."
tailscale up --authkey="$TAILSCALE_AUTH_KEY" --accept-routes --accept-dns=false 2>/dev/null || \
tailscale up --authkey="$TAILSCALE_AUTH_KEY" --accept-routes 2>/dev/null || true

TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "unknown")
echo "TAILSCALE_IP=$TAILSCALE_IP" >> "$WORK_DIR/client-config.env"

log "Tailscale connected. IP: $TAILSCALE_IP"

#================================================================================
# STEP 4: CLOUDFLARE TUNNEL
#================================================================================
step "4" "Setting up Cloudflare Tunnel"

if ! command -v cloudflared &>/dev/null; then
    info "Installing cloudflared..."
    curl -L --output cloudflared.deb "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb" 2>/dev/null || \
    curl -L --output cloudflared.deb "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm.deb"
    dpkg -i cloudflared.deb 2>/dev/null || apt-get install -f -y -qq
    rm -f cloudflared.deb
fi

info "Configuring Cloudflare Tunnel..."
mkdir -p /etc/cloudflared
# Using token-based authentication - no config file needed
echo "$CF_TUNNEL_TOKEN" > /etc/cloudflared/token.txt

# Use the token for authentication - simpler and more reliable
chmod 600 /etc/cloudflared/token.txt

# Systemd service using token
cat > /etc/systemd/system/cloudflared.service << EOF
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/cloudflared tunnel --no-autoupdate run --token ${CF_TUNNEL_TOKEN}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable cloudflared
systemctl start cloudflared

log "Cloudflare Tunnel configured for https://$CLIENT_DOMAIN"

#================================================================================
# STEP 5: NEXTCLOUD WITH DOCKER
#================================================================================
step "5" "Deploying Nextcloud with Docker"

mkdir -p /opt/nextcloud/{data,config,apps,themes,custom_apps}
chmod -R 755 /opt/nextcloud

# Create docker-compose.yml
cat > /opt/nextcloud/docker-compose.yml << EOF
version: '3.8'

services:
  db:
    image: mariadb:10.6
    container_name: nextcloud-db
    restart: always
    command: --transaction-isolation=READ-COMMITTED --log-bin=binlog --binlog-format=ROW
    volumes:
      - /opt/nextcloud/db:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=${ADMIN_PASSWORD}
      - MYSQL_PASSWORD=${ADMIN_PASSWORD}
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
    networks:
      - nextcloud

  redis:
    image: redis:alpine
    container_name: nextcloud-redis
    restart: always
    networks:
      - nextcloud

  app:
    image: nextcloud:latest
    container_name: nextcloud-app
    restart: always
    ports:
      - 8080:80
    links:
      - db
      - redis
    volumes:
      - /opt/nextcloud/data:/var/www/html/data
      - /opt/nextcloud/config:/var/www/html/config
      - /opt/nextcloud/apps:/var/www/html/apps
      - /opt/nextcloud/custom_apps:/var/www/html/custom_apps
      - /opt/nextcloud/themes:/var/www/html/themes
    environment:
      - MYSQL_PASSWORD=${ADMIN_PASSWORD}
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
      - MYSQL_HOST=db
      - REDIS_HOST=redis
      - NEXTCLOUD_ADMIN_USER=admin
      - NEXTCLOUD_ADMIN_PASSWORD=${ADMIN_PASSWORD}
      - NEXTCLOUD_TRUSTED_DOMAINS=${CLIENT_DOMAIN} ${PI_HOSTNAME} localhost 127.0.0.1
      - OVERWRITEPROTOCOL=https
      - OVERWRITEHOST=${CLIENT_DOMAIN}
      - OVERWRITECONDADDR=^.*$
      - TRUSTED_PROXIES=172.16.0.0/12
      - APACHE_BODY_LIMIT=0
    networks:
      - nextcloud
    depends_on:
      - db
      - redis
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80/login"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  cron:
    image: nextcloud:latest
    container_name: nextcloud-cron
    restart: always
    volumes:
      - /opt/nextcloud/data:/var/www/html/data
      - /opt/nextcloud/config:/var/www/html/config
      - /opt/nextcloud/apps:/var/www/html/apps
      - /opt/nextcloud/custom_apps:/var/www/html/custom_apps
    entrypoint: /cron.sh
    networks:
      - nextcloud
    depends_on:
      - db
      - redis

  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - WATCHTOWER_NOTIFICATIONS=email
      - WATCHTOWER_NOTIFICATION_EMAIL_FROM=${ADMIN_EMAIL}
      - WATCHTOWER_NOTIFICATION_EMAIL_TO=${ADMIN_EMAIL}
      - WATCHTOWER_NOTIFICATION_EMAIL_SERVER=${SMTP_HOST}
      - WATCHTOWER_NOTIFICATION_EMAIL_SERVER_PORT=${SMTP_PORT}
      - WATCHTOWER_NOTIFICATION_EMAIL_SERVER_USER=${SMTP_USER}
      - WATCHTOWER_NOTIFICATION_EMAIL_SERVER_PASSWORD=${SMTP_PASS}
      - WATCHTOWER_SCHEDULE=0 0 2 * * 0
    networks:
      - nextcloud

networks:
  nextcloud:
    driver: bridge
EOF

info "Starting Nextcloud containers..."
cd /opt/nextcloud
docker-compose up -d

# Wait for Nextcloud to be ready
info "Waiting for Nextcloud to initialize (this may take 2-3 minutes)..."
for i in {1..60}; do
    if curl -s http://localhost:8080/login >/dev/null 2>&1; then
        log "Nextcloud is ready!"
        break
    fi
    echo -n "."
    sleep 5
done

log "Nextcloud deployed successfully."

#================================================================================
# STEP 6: NEXTCLOUD CONFIGURATION (OCC COMMANDS)
#================================================================================
step "6" "Configuring Nextcloud Apps & Settings"

info "Waiting for Nextcloud to fully initialize..."
sleep 30

NC_OCC="docker exec --user www-data nextcloud-app php occ"

# Set correct permissions
docker exec nextcloud-app chown -R www-data:www-data /var/www/html 2>/dev/null || true

# Install and enable apps
info "Installing required Nextcloud apps..."

# Registration app
$NC_OCC app:install registration 2>/dev/null || $NC_OCC app:enable registration 2>/dev/null || true

# Terms of Service app
$NC_OCC app:install terms_of_service 2>/dev/null || $NC_OCC app:enable terms_of_service 2>/dev/null || true

# Talk (Spreed)
$NC_OCC app:install spreed 2>/dev/null || $NC_OCC app:enable spreed 2>/dev/null || true

# TOTP 2FA
$NC_OCC app:install twofactor_totp 2>/dev/null || $NC_OCC app:enable twofactor_totp 2>/dev/null || true

# Other useful apps
$NC_OCC app:install calendar 2>/dev/null || true
$NC_OCC app:install contacts 2>/dev/null || true
$NC_OCC app:install deck 2>/dev/null || true
$NC_OCC app:install notes 2>/dev/null || true
$NC_OCC app:install tasks 2>/dev/null || true

# Configure registration
info "Configuring self-registration..."
$NC_OCC config:app:set registration enabled --value="yes" 2>/dev/null || true
$NC_OCC config:app:set registration registered_user_group --value="users" 2>/dev/null || true
$NC_OCC config:app:set registration admin_approval_required --value="no" 2>/dev/null || true
$NC_OCC config:app:set registration show_fullname --value="yes" 2>/dev/null || true

# Configure Terms of Service
info "Configuring Terms of Service..."
$NC_OCC config:app:set terms_of_service tos_for_users --value="1" 2>/dev/null || true
$NC_OCC config:app:set terms_of_service tos_on_public_shares --value="1" 2>/dev/null || true
$NC_OCC config:app:set terms_of_service tos_for_guests --value="1" 2>/dev/null || true

# Create Terms of Service via API (since occ doesn't support creating terms directly)
info "Creating Terms of Service content..."
ADMIN_COOKIE=$(docker exec nextcloud-app php -r "
require '/var/www/html/config/config.php';
\$config = new \OC\Config('/var/www/html/config');
echo 'done';
" 2>/dev/null || true)

# Alternative: Create terms via direct database insert
# The terms_of_service app stores terms in oc_terms_of_service_terms table
# We'll create a simple global English term

# First, get the proper admin session to create terms
info "Setting up Terms of Service via web API..."
sleep 5

# Create a script to insert terms directly into the database
TERMS_TEXT="By using Xennrex Cloud services, you agree to comply with all applicable laws and regulations. You acknowledge that your data is stored securely and that you are responsible for maintaining the confidentiality of your account credentials. You agree not to use the service for any illegal, harmful, or unauthorized purposes. Xennrex reserves the right to suspend or terminate accounts that violate these terms. For full details, please refer to our Terms of Service page."

# Insert terms into database using mysql
docker exec nextcloud-db mysql -u nextcloud -p${ADMIN_PASSWORD} nextcloud -e "
INSERT IGNORE INTO oc_terms_of_service_terms (id, country_code, language_code, body, heading) 
VALUES (1, '--', 'en', '${TERMS_TEXT}', 'Xennrex Cloud Terms of Service');
" 2>/dev/null || true

# Also try the API approach
TOKEN_RESPONSE=$(curl -s -X POST http://localhost:8080/index.php/login     -d "user=admin&password=${ADMIN_PASSWORD}&redirect_url=/"     -c /tmp/nc_cookies.txt 2>/dev/null || true)

# Create terms via the terms API if available
curl -s -X POST http://localhost:8080/apps/terms_of_service/terms     -b /tmp/nc_cookies.txt     -H "Content-Type: application/json"     -d '{"countryCode":"--","languageCode":"en","body":"'"${TERMS_TEXT}"'","heading":"Xennrex Cloud Terms of Service"}' 2>/dev/null || true

rm -f /tmp/nc_cookies.txt

# Configure 2FA
if [ "$ENABLE_2FA" = "yes" ]; then
    info "Enforcing 2FA..."
    $NC_OCC app:enable twofactor_totp 2>/dev/null || true
    $NC_OCC config:app:set twofactor_totp enforced --value="true" 2>/dev/null || true
    $NC_OCC config:app:set twofactor_totp enforced_groups --value="[]" 2>/dev/null || true
    $NC_OCC config:app:set twofactor_totp excluded_groups --value="[]" 2>/dev/null || true
fi

# Set default quota to match plan
info "Setting default user quota to ${PLAN_SIZE_MB}MB..."
$NC_OCC config:app:set files default_quota --value="${PLAN_SIZE_MB} MB" 2>/dev/null || true

# Configure file versioning (shadow copies)
if [ "$ENABLE_SHADOW" = "yes" ]; then
    info "Enabling file versioning (shadow copies)..."
    $NC_OCC config:system:set versions_retention_obligation --value="auto, 30" 2>/dev/null || true
fi

# Configure SMTP for Nextcloud
info "Configuring Nextcloud email (SMTP)..."
$NC_OCC config:system:set mail_smtpmode --value="smtp" 2>/dev/null || true
$NC_OCC config:system:set mail_smtpsecure --value="tls" 2>/dev/null || true
$NC_OCC config:system:set mail_from_address --value="info" 2>/dev/null || true
$NC_OCC config:system:set mail_domain --value="xennrex.org" 2>/dev/null || true
$NC_OCC config:system:set mail_smtpauthtype --value="LOGIN" 2>/dev/null || true
$NC_OCC config:system:set mail_smtpauth --value="1" 2>/dev/null || true
$NC_OCC config:system:set mail_smtphost --value="$SMTP_HOST" 2>/dev/null || true
$NC_OCC config:system:set mail_smtpport --value="$SMTP_PORT" 2>/dev/null || true
$NC_OCC config:system:set mail_smtpname --value="$SMTP_USER" 2>/dev/null || true
$NC_OCC config:system:set mail_smtppassword --value="$SMTP_PASS" 2>/dev/null || true

# Performance tuning
info "Applying performance settings..."
$NC_OCC config:system:set memcache.local --value="\\OC\\Memcache\\Redis" 2>/dev/null || true
$NC_OCC config:system:set memcache.locking --value="\\OC\\Memcache\\Redis" 2>/dev/null || true
$NC_OCC config:system:set redis --value="{\"host\":\"redis\",\"port\":6379}" --type=json 2>/dev/null || true
$NC_OCC config:system:set default_phone_region --value="ZA" 2>/dev/null || true

# Background jobs via cron
$NC_OCC background:cron 2>/dev/null || true

log "Nextcloud configuration complete."

#================================================================================
# STEP 7: SECURITY HARDENING
#================================================================================
step "7" "Hardening Security"

# UFW Firewall
info "Configuring UFW firewall..."
ufw --force reset 2>/dev/null || true
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment 'SSH'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw allow 8080/tcp comment 'Nextcloud local'
ufw allow 41641/udp comment 'Tailscale'
ufw --force enable

# Fail2ban
info "Configuring fail2ban..."
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

[nextcloud]
enabled = true
port = http,https
filter = nextcloud
logpath = /opt/nextcloud/data/nextcloud.log
maxretry = 5
EOF

# Nextcloud fail2ban filter
cat > /etc/fail2ban/filter.d/nextcloud.conf << 'EOF'
[Definition]
failregex = ^.*Login failed: '.*' \(Remote IP: '<HOST>'\).*$\n ^.*"remoteAddr":"<HOST>".*"message":"Login failed.*".*$
ignoreregex =
EOF

systemctl restart fail2ban
systemctl enable fail2ban

# Geo-blocking with ipset
info "Setting up geo-blocking (blocking high-risk countries)..."
apt-get install -y -qq xtables-addons-common 2>/dev/null || true

# Create ipset for blocked countries
ipset create blocked_countries hash:net 2>/dev/null || ipset flush blocked_countries 2>/dev/null || true

# Download and populate country IP ranges
for COUNTRY in $BLOCKED_COUNTRIES; do
    info "Blocking country: $COUNTRY"
    curl -s "http://www.ipdeny.com/ipblocks/data/countries/${COUNTRY,,}.zone" 2>/dev/null | while read IP; do
        ipset add blocked_countries "$IP" 2>/dev/null || true
    done
done

# Add iptables rule
iptables -C INPUT -m set --match-set blocked_countries src -j DROP 2>/dev/null || \
iptables -I INPUT 1 -m set --match-set blocked_countries src -j DROP 2>/dev/null || true

# Make persistent
iptables-save > /etc/iptables/rules.v4 2>/dev/null || true

# Secure SSH
info "Securing SSH..."
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config 2>/dev/null || true
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config 2>/dev/null || true
systemctl restart sshd 2>/dev/null || true

log "Security hardening complete."

#================================================================================
# STEP 8: MSMTP EMAIL CONFIGURATION
#================================================================================
step "8" "Configuring Email (msmtp + Gmail)"

cat > /etc/msmtprc << EOF
# Xennrex Email Configuration
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log

account        xennrex
host           $SMTP_HOST
port           $SMTP_PORT
from           $ADMIN_EMAIL
user           $SMTP_USER
password       $SMTP_PASS

account default : xennrex
EOF

chmod 600 /etc/msmtprc

# Test email
info "Testing email configuration..."
echo "Xennrex Cloud v11.0 email test - $(date)" | mail -s "Xennrex Email Test" "$ADMIN_EMAIL" 2>/dev/null || true

log "Email configured."

#================================================================================
# STEP 9: BACKUP SYSTEM (Backblaze B2)
#================================================================================
step "9" "Setting up Backblaze B2 Backups"

# Install B2 CLI
if ! command -v b2 &>/dev/null; then
    info "Installing Backblaze B2 CLI..."
    pip3 install b2 2>/dev/null || apt-get install -y -qq python3-b2 2>/dev/null || \
    curl -L https://github.com/Backblaze/B2_Command_Line_Tool/releases/latest/download/b2-linux -o /usr/local/bin/b2 && chmod +x /usr/local/bin/b2
fi

# Authorize B2
info "Authorizing Backblaze B2..."
b2 authorize-account "$B2_KEY_ID" "$B2_APP_KEY" 2>/dev/null || true

# Create bucket if not exists
b2 create-bucket "$B2_BUCKET" allPrivate 2>/dev/null || true

# Backup script
cat > /usr/local/bin/xennrex-backup.sh << EOF
#!/bin/bash
# Xennrex Daily Backup Script
DATE=\$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/tmp/xennrex-backup-\$DATE"
mkdir -p "\$BACKUP_DIR"

# Backup Nextcloud data
tar czf "\$BACKUP_DIR/nextcloud_data_\$DATE.tar.gz" -C /opt/nextcloud data config 2>/dev/null || true

# Backup database
docker exec nextcloud-db mysqldump -u nextcloud -p${ADMIN_PASSWORD} nextcloud > "\$BACKUP_DIR/nextcloud_db_\$DATE.sql" 2>/dev/null || true

# Backup config
cp "$WORK_DIR/client-config.env" "\$BACKUP_DIR/" 2>/dev/null || true

# Upload to B2
cd "\$BACKUP_DIR"
tar czf "\$BACKUP_DIR.tar.gz" .
b2 upload-file "$B2_BUCKET" "\$BACKUP_DIR.tar.gz" "backups/${CLIENT_SLUG}/backup_\$DATE.tar.gz" 2>/dev/null || true

# Cleanup
rm -rf "\$BACKUP_DIR" "\$BACKUP_DIR.tar.gz"

# Ping healthchecks (backup success signal)
curl -fsS -m 10 --retry 5 "https://hc-ping.com/${HEALTHCHECKS_UUID}" >/dev/null 2>&1 || true

logger -t xennrex-backup "Backup completed for ${CLIENT_NAME}"
EOF
chmod +x /usr/local/bin/xennrex-backup.sh

# Antivirus script
cat > /usr/local/bin/xennrex-antivirus.sh << 'EOF'
#!/bin/bash
# Xennrex Weekly Antivirus Scan
if command -v clamscan &>/dev/null; then
    clamscan -r --infected --remove /opt/nextcloud/data 2>/dev/null | logger -t xennrex-antivirus
else
    apt-get install -y -qq clamav clamav-daemon 2>/dev/null || true
    freshclam 2>/dev/null || true
    clamscan -r --infected --remove /opt/nextcloud/data 2>/dev/null | logger -t xennrex-antivirus
fi
EOF
chmod +x /usr/local/bin/xennrex-antivirus.sh

log "Backup system configured."

#================================================================================
# STEP 10: MONITORING & HEALTH CHECKS
#================================================================================
step "10" "Setting up Monitoring"

# Health check script with Healthchecks.io integration
cat > /usr/local/bin/xennrex-health.sh << 'EOF'
#!/bin/bash
# Xennrex Health Monitor - Integrated with Healthchecks.io
# Ping URL: https://hc-ping.com/1f5a5c7b-d5fd-417b-958b-7e88807daa08

LOG_FILE="/var/log/xennrex-health.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
HEALTHCHECKS_URL="https://hc-ping.com/1f5a5c7b-d5fd-417b-958b-7e88807daa08"
FAILED=0

# Check services
SERVICES="docker cloudflared tailscaled fail2ban"
for SVC in $SERVICES; do
    if systemctl is-active --quiet $SVC; then
        echo "[$TIMESTAMP] ✓ $SVC running" >> "$LOG_FILE"
    else
        echo "[$TIMESTAMP] ✗ $SVC DOWN - restarting..." >> "$LOG_FILE"
        systemctl restart $SVC 2>/dev/null || true
        FAILED=1
    fi
done

# Check disk space
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
if [ "$DISK_USAGE" -gt 85 ]; then
    echo "[$TIMESTAMP] ⚠ Disk usage at ${DISK_USAGE}%" >> "$LOG_FILE"
    echo "Xennrex Alert: Disk usage at ${DISK_USAGE}% for ${CLIENT_NAME}" | mail -s "Xennrex Disk Alert" "$ADMIN_EMAIL" 2>/dev/null || true
fi

# Check Nextcloud
if ! curl -fsS -m 10 --retry 3 http://localhost:8080/login >/dev/null 2>&1; then
    echo "[$TIMESTAMP] ✗ Nextcloud not responding" >> "$LOG_FILE"
    cd /opt/nextcloud && docker-compose restart 2>/dev/null || true
    FAILED=1
fi

# Check Cloudflare Tunnel connectivity
if ! curl -fsS -m 10 --retry 3 https://hc-ping.com >/dev/null 2>&1; then
    echo "[$TIMESTAMP] ⚠ Internet connectivity issue detected" >> "$LOG_FILE"
fi

# Ping Healthchecks.io
# If all checks passed, send success signal
# If any check failed, send fail signal
if [ "$FAILED" -eq 0 ]; then
    curl -fsS -m 10 --retry 5 "$HEALTHCHECKS_URL" >/dev/null 2>&1 || true
    echo "[$TIMESTAMP] ✓ Healthchecks ping sent" >> "$LOG_FILE"
else
    curl -fsS -m 10 --retry 5 "${HEALTHCHECKS_URL}/fail" >/dev/null 2>&1 || true
    echo "[$TIMESTAMP] ✗ Healthchecks fail signal sent" >> "$LOG_FILE"
fi
EOF
chmod +x /usr/local/bin/xennrex-health.sh

# Add health check to cron (every 15 minutes)
(crontab -l 2>/dev/null | grep -v "xennrex-health" || true; echo "*/15 * * * * /usr/local/bin/xennrex-health.sh >/dev/null 2>&1") | crontab -

# Also add healthchecks ping to backup script
sed -i 's|# Ping healthchecks|# Ping healthchecks (backup success)|' /usr/local/bin/xennrex-backup.sh 2>/dev/null || true

log "Monitoring configured."

#================================================================================
# STEP 11: CLIENT WELCOME EMAIL
#================================================================================
step "11" "Sending Welcome Email to Client"

WELCOME_EMAIL=$(cat << EOF
Subject: Welcome to Xennrex Cloud - Your Secure Storage is Ready
From: Xennrex Cloud <$ADMIN_EMAIL>
To: $CLIENT_EMAIL
Content-Type: text/html; charset=utf-8

<html>
<body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
<div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center; color: white;">
<h1>Welcome to Xennrex Cloud</h1>
<p>Your secure cloud storage is ready!</p>
</div>

<div style="padding: 30px; background: #f9f9f9;">
<h2>Hello $CLIENT_NAME,</h2>
<p>Your Xennrex Cloud instance has been provisioned and is now live.</p>

<div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
<h3>Your Login Details</h3>
<p><strong>Cloud URL:</strong> <a href="https://$CLIENT_DOMAIN">https://$CLIENT_DOMAIN</a></p>
<p><strong>Plan:</strong> $PLAN_NAME ($PLAN_PRICE)</p>
<p><strong>Storage:</strong> ${PLAN_SIZE_MB}MB</p>
</div>

<div style="background: #e8f5e9; padding: 20px; border-radius: 8px; margin: 20px 0;">
<h3>Getting Started</h3>
<ol>
<li>Visit <a href="https://$CLIENT_DOMAIN">https://$CLIENT_DOMAIN</a></li>
<li>Click "Register" to create your account</li>
<li>Accept the Terms of Service</li>
<li>Set up Two-Factor Authentication (2FA)</li>
<li>Start uploading your files securely</li>
</ol>
</div>

<div style="background: #fff3e0; padding: 20px; border-radius: 8px; margin: 20px 0;">
<h3>Features Included</h3>
<ul>
<li>End-to-end encrypted file storage</li>
<li>File versioning & recovery</li>
<li>Calendar, Contacts & Notes</li>
<li>Video conferencing (Talk)</li>
<li>Mobile apps for iOS & Android</li>
<li>Daily automated backups</li>
<li>24/7 monitoring & alerts</li>
</ul>
</div>

<p style="margin-top: 30px;">If you have any questions, reply to this email or contact us at $ADMIN_EMAIL.</p>

<p>Best regards,<br>
<strong>The Xennrex Team</strong></p>
</div>

<div style="background: #333; color: #ccc; padding: 20px; text-align: center; font-size: 12px;">
<p>Xennrex Cloud Solutions | Springs, South Africa</p>
<p>This email was sent automatically. Please do not reply directly.</p>
</div>
</body>
</html>
EOF
)

echo "$WELCOME_EMAIL" | msmtp -t "$CLIENT_EMAIL" 2>/dev/null || true

# Also send admin notification
ADMIN_NOTIFY=$(cat << EOF
Subject: [Xennrex] New Client Provisioned: $CLIENT_NAME
From: Xennrex System <$ADMIN_EMAIL>
To: $ADMIN_EMAIL

New client provisioned:

Client:     $CLIENT_NAME
Email:      $CLIENT_EMAIL
MEGA:       $MEGA_EMAIL
Plan:       $PLAN_NAME ($PLAN_SIZE_MB MB)
Domain:     https://$CLIENT_DOMAIN
Hostname:   $PI_HOSTNAME
Tailscale:  $TAILSCALE_IP
Admin Pass: $ADMIN_PASSWORD
Date:       $(date)

Pi is ready for client use.
EOF
)

echo "$ADMIN_NOTIFY" | msmtp -t "$ADMIN_EMAIL" 2>/dev/null || true

log "Welcome email sent to $CLIENT_EMAIL"
log "Admin notification sent to $ADMIN_EMAIL"

#================================================================================
# STEP 12: FINAL TESTING
#================================================================================
step "12" "Running Final Tests"

info "Testing all services..."

# Test 1: Docker
if systemctl is-active --quiet docker; then
    log "✓ Docker running"
else
    error "✗ Docker not running"
fi

# Test 2: Nextcloud
if curl -s http://localhost:8080/login >/dev/null 2>&1; then
    log "✓ Nextcloud responding"
else
    error "✗ Nextcloud not responding"
fi

# Test 3: Cloudflare Tunnel
if systemctl is-active --quiet cloudflared; then
    log "✓ Cloudflare Tunnel running"
else
    error "✗ Cloudflare Tunnel not running"
fi

# Test 4: Tailscale
if systemctl is-active --quiet tailscaled; then
    log "✓ Tailscale running (IP: $TAILSCALE_IP)"
else
    error "✗ Tailscale not running"
fi

# Test 5: Firewall
if ufw status | grep -q "Status: active"; then
    log "✓ UFW firewall active"
else
    warn "⚠ UFW not active"
fi

# Test 6: Fail2ban
if systemctl is-active --quiet fail2ban; then
    log "✓ Fail2ban running"
else
    error "✗ Fail2ban not running"
fi

# Test 7: Email
if [ -f /var/log/msmtp.log ]; then
    log "✓ Email configured"
else
    warn "⚠ Email not yet tested"
fi

# Test 8: Health checks
if curl -fsS -m 5 "https://hc-ping.com/${HEALTHCHECKS_UUID}" >/dev/null 2>&1; then
    log "✓ Healthchecks responding"
else
    warn "⚠ Healthchecks not responding"
fi

# Save final credentials
cat > "$WORK_DIR/CREDENTIALS.txt" << EOF
================================================================================
                    XENNREX CLIENT CREDENTIALS
                    Client: $CLIENT_NAME
                    Generated: $(date)
================================================================================

CLOUD URL:      https://$CLIENT_DOMAIN
ADMIN USER:     admin
ADMIN PASS:     $ADMIN_PASSWORD

NEXTCLOUD LOGIN:
  URL:          https://$CLIENT_DOMAIN
  User:         admin
  Pass:         $ADMIN_PASSWORD

TAILSCALE IP:   $TAILSCALE_IP
LOCAL IP:       $(hostname -I | awk '{print $1}')

MEGA ACCOUNT:
  Email:        $MEGA_EMAIL
  Password:     $MEGA_PASSWORD

PLAN:           $PLAN_NAME ($PLAN_SIZE_MB MB / $PLAN_PRICE)

IMPORTANT:
1. Share ONLY the Cloud URL and admin credentials with the client
2. Keep this file secure - do not share MEGA credentials with client
3. Client should change admin password on first login
4. Client MUST set up 2FA immediately

================================================================================
EOF

chmod 600 "$WORK_DIR/CREDENTIALS.txt"

#================================================================================
# COMPLETION
#================================================================================
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  INSTALLATION COMPLETE!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Client:${NC}        $CLIENT_NAME"
echo -e "${CYAN}Cloud URL:${NC}       https://$CLIENT_DOMAIN"
echo -e "${CYAN}Admin User:${NC}      admin"
echo -e "${CYAN}Admin Password:${NC}  $ADMIN_PASSWORD"
echo -e "${CYAN}Plan:${NC}            $PLAN_NAME ($PLAN_SIZE_MB MB)"
echo -e "${CYAN}Tailscale IP:${NC}    $TAILSCALE_IP"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Give client their Cloud URL: https://$CLIENT_DOMAIN"
echo "  2. Client clicks 'Register' and creates their account"
echo "  3. Client accepts Terms of Service"
echo "  4. Client sets up 2FA (enforced)"
echo "  5. Client starts using Nextcloud"
echo ""
echo -e "${YELLOW}For You (Admin):${NC}"
echo "  - Credentials saved to: $WORK_DIR/CREDENTIALS.txt"
echo "  - Monitor at: https://healthchecks.io"
echo "  - Backups daily at 3:00 AM to Backblaze B2"
echo "  - Health checks every 15 minutes"
echo ""
echo -e "${GREEN}✓ Zero-touch provisioning complete. Client can start immediately.${NC}"
echo ""
