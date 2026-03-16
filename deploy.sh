#!/bin/bash
# ============================================================
# IFFSOO Gold Herbal — Deploy Script
# Usage: bash deploy.sh
# Jalankan dari folder project (iffsoo/) di laptop lo
# ============================================================

set -e

# --- CONFIG ---
SERVER_IP="157.173.195.82"
SERVER_PORT="2220"
SERVER_USER="root"
SERVER_PASS="R8gJQ3RwIw55G"
DOMAIN="iffsoo.gold"
WEB_ROOT="/var/www/iffsoo"

# Warna output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# Check dependency
if ! command -v sshpass &>/dev/null; then
  warn "sshpass tidak ditemukan. Install dulu:"
  echo ""
  echo "  Mac:   brew install sshpass"
  echo "  Ubuntu: sudo apt install sshpass"
  echo "  Debian: sudo apt install sshpass"
  echo ""
  exit 1
fi

SSH_CMD="sshpass -p '${SERVER_PASS}' ssh -o StrictHostKeyChecking=no -p ${SERVER_PORT} ${SERVER_USER}@${SERVER_IP}"
SCP_CMD="sshpass -p '${SERVER_PASS}' scp -o StrictHostKeyChecking=no -P ${SERVER_PORT}"

echo ""
echo "============================================"
echo "  IFFSOO Deploy — ${DOMAIN}"
echo "============================================"
echo ""

# 1. Test koneksi
log "Testing koneksi ke server..."
sshpass -p "${SERVER_PASS}" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
  -p ${SERVER_PORT} ${SERVER_USER}@${SERVER_IP} "echo 'Connected'" \
  || err "Tidak bisa konek ke server. Cek IP/port/firewall."
log "Koneksi OK"

# 2. Install Nginx jika belum ada
log "Cek & install Nginx..."
sshpass -p "${SERVER_PASS}" ssh -o StrictHostKeyChecking=no -p ${SERVER_PORT} \
  ${SERVER_USER}@${SERVER_IP} "
    if ! command -v nginx &>/dev/null; then
      apt-get update -qq && apt-get install -y nginx
    fi
    systemctl enable nginx
    systemctl start nginx
    echo 'Nginx version:' \$(nginx -v 2>&1)
  "
log "Nginx siap"

# 3. Buat web root
log "Setup web root: ${WEB_ROOT}"
sshpass -p "${SERVER_PASS}" ssh -o StrictHostKeyChecking=no -p ${SERVER_PORT} \
  ${SERVER_USER}@${SERVER_IP} "mkdir -p ${WEB_ROOT}/assets/Photos-3-001"
log "Web root siap"

# 4. Upload HTML files
log "Upload landing page files..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for f in "${SCRIPT_DIR}"/lp-*.html; do
  filename=$(basename "$f")
  sshpass -p "${SERVER_PASS}" scp -o StrictHostKeyChecking=no -P ${SERVER_PORT} \
    "$f" ${SERVER_USER}@${SERVER_IP}:${WEB_ROOT}/
  echo "  → ${filename}"
done

# Set lp-hard-sell-direct.html sebagai index default
sshpass -p "${SERVER_PASS}" ssh -o StrictHostKeyChecking=no -p ${SERVER_PORT} \
  ${SERVER_USER}@${SERVER_IP} "
    if [ -f ${WEB_ROOT}/lp-hard-sell-direct.html ]; then
      cp ${WEB_ROOT}/lp-hard-sell-direct.html ${WEB_ROOT}/index.html
    fi
  "
log "HTML files uploaded"

# 5. Upload assets
log "Upload assets..."
if [ -d "${SCRIPT_DIR}/assets" ]; then
  sshpass -p "${SERVER_PASS}" scp -o StrictHostKeyChecking=no -P ${SERVER_PORT} -r \
    "${SCRIPT_DIR}/assets/" ${SERVER_USER}@${SERVER_IP}:${WEB_ROOT}/
  log "Assets uploaded"
else
  warn "Folder assets/ tidak ditemukan, skip"
fi

# 6. Konfigurasi Nginx
log "Konfigurasi Nginx untuk domain ${DOMAIN}..."
sshpass -p "${SERVER_PASS}" ssh -o StrictHostKeyChecking=no -p ${SERVER_PORT} \
  ${SERVER_USER}@${SERVER_IP} "cat > /etc/nginx/sites-available/iffsoo << 'NGINXCONF'
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} www.${DOMAIN};

    root ${WEB_ROOT};
    index index.html lp-hard-sell-direct.html;

    # Gzip
    gzip on;
    gzip_types text/html text/css application/javascript image/webp image/jpeg image/png;

    # Cache assets
    location /assets/ {
        expires 30d;
        add_header Cache-Control \"public, no-transform\";
    }

    # Main
    location / {
        try_files \$uri \$uri/ =404;
    }

    # Security headers
    add_header X-Frame-Options \"SAMEORIGIN\";
    add_header X-Content-Type-Options \"nosniff\";
}
NGINXCONF"

# Enable site
sshpass -p "${SERVER_PASS}" ssh -o StrictHostKeyChecking=no -p ${SERVER_PORT} \
  ${SERVER_USER}@${SERVER_IP} "
    ln -sf /etc/nginx/sites-available/iffsoo /etc/nginx/sites-enabled/iffsoo
    rm -f /etc/nginx/sites-enabled/default
    nginx -t && systemctl reload nginx
  "
log "Nginx dikonfigurasi"

# 7. Set permissions
sshpass -p "${SERVER_PASS}" ssh -o StrictHostKeyChecking=no -p ${SERVER_PORT} \
  ${SERVER_USER}@${SERVER_IP} "chown -R www-data:www-data ${WEB_ROOT} && chmod -R 755 ${WEB_ROOT}"
log "Permissions set"

# 8. Summary
echo ""
echo "============================================"
log "DEPLOY SELESAI!"
echo "============================================"
echo ""
echo "  Site aktif di: http://${DOMAIN}"
echo ""
echo "  Landing pages:"
sshpass -p "${SERVER_PASS}" ssh -o StrictHostKeyChecking=no -p ${SERVER_PORT} \
  ${SERVER_USER}@${SERVER_IP} "ls ${WEB_ROOT}/lp-*.html 2>/dev/null | xargs -I{} basename {}" \
  | while read f; do echo "  → http://${DOMAIN}/${f}"; done

echo ""
warn "Next step: arahkan DNS iffsoo.gold → ${SERVER_IP}"
warn "Optional: install SSL dengan: certbot --nginx -d ${DOMAIN} -d www.${DOMAIN}"
echo ""
