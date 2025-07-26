#!/bin/bash

# 2025-01-27: invenone.it.kr 도메인 SSL 인증서 설정 스크립트
# QR 자산관리 시스템 HTTPS 설정

echo "=== invenone.it.kr SSL 인증서 설정 시작 ==="

# 도메인 설정
DOMAIN="invenone.it.kr"
EMAIL="admin@invenone.it.kr"  # 관리자 이메일 주소로 변경하세요

# 필요한 패키지 설치 확인
echo "1. 필요한 패키지 설치 확인 중..."
if ! command -v certbot &> /dev/null; then
    echo "certbot이 설치되지 않았습니다. 설치를 진행합니다..."
    sudo apt update
    sudo apt install -y certbot python3-certbot-nginx
else
    echo "certbot이 이미 설치되어 있습니다."
fi

# nginx 설정 파일 백업
echo "2. 기존 nginx 설정 백업 중..."
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup.$(date +%Y%m%d_%H%M%S)

# 임시 HTTP 설정으로 nginx 재시작 (인증서 발급을 위해)
echo "3. 임시 HTTP 설정 적용 중..."
sudo tee /etc/nginx/sites-available/invenone-temp << EOF
server {
    listen 80;
    server_name $DOMAIN;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
    
    location /api/ {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# 임시 설정 활성화
sudo ln -sf /etc/nginx/sites-available/invenone-temp /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# Let's Encrypt 인증서 발급
echo "4. Let's Encrypt SSL 인증서 발급 중..."
sudo certbot --nginx -d $DOMAIN --email $EMAIL --agree-tos --non-interactive

# 인증서 발급 성공 확인
if [ $? -eq 0 ]; then
    echo "5. SSL 인증서 발급 성공!"
    
    # 최종 HTTPS 설정 적용
    echo "6. 최종 HTTPS 설정 적용 중..."
    sudo cp nginx-invenone-ssl.conf /etc/nginx/sites-available/invenone-ssl
    
    # Let's Encrypt 인증서 경로로 설정 파일 수정
    sudo sed -i "s|ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;|ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;|g" /etc/nginx/sites-available/invenone-ssl
    sudo sed -i "s|ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;|ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;|g" /etc/nginx/sites-available/invenone-ssl
    
    # 임시 설정 제거 및 최종 설정 활성화
    sudo rm -f /etc/nginx/sites-enabled/invenone-temp
    sudo ln -sf /etc/nginx/sites-available/invenone-ssl /etc/nginx/sites-enabled/
    
    # nginx 설정 테스트 및 재시작
    sudo nginx -t
    if [ $? -eq 0 ]; then
        sudo systemctl reload nginx
        echo "7. nginx 설정 적용 완료!"
    else
        echo "오류: nginx 설정 테스트 실패"
        exit 1
    fi
    
    # 자동 갱신 설정
    echo "8. 자동 갱신 설정 중..."
    sudo crontab -l 2>/dev/null | { cat; echo "0 12 * * * /usr/bin/certbot renew --quiet"; } | sudo crontab -
    
    echo "=== SSL 설정 완료 ==="
    echo "도메인: https://$DOMAIN"
    echo "인증서 자동 갱신이 매일 오후 12시에 실행됩니다."
    
else
    echo "오류: SSL 인증서 발급 실패"
    echo "다음을 확인하세요:"
    echo "1. 도메인 DNS 설정이 올바른지 확인"
    echo "2. 80번 포트가 열려있는지 확인"
    echo "3. 방화벽 설정 확인"
    exit 1
fi

echo "=== 설정 완료 ===" 