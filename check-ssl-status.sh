#!/bin/bash

# 2025-01-27: invenone.it.kr SSL 상태 확인 스크립트
# QR 자산관리 시스템 SSL 인증서 및 도메인 연결 상태 점검

echo "=== invenone.it.kr SSL 상태 확인 ==="
echo "확인 시간: $(date)"
echo ""

# 도메인 설정
DOMAIN="invenone.it.kr"

# 1. DNS 확인
echo "1. DNS 설정 확인 중..."
DNS_RESULT=$(nslookup $DOMAIN 2>/dev/null | grep "Address:" | tail -1 | awk '{print $2}')
if [ ! -z "$DNS_RESULT" ]; then
    echo "✓ DNS 확인 성공: $DOMAIN -> $DNS_RESULT"
else
    echo "✗ DNS 확인 실패: $DOMAIN"
fi
echo ""

# 2. HTTP 연결 확인
echo "2. HTTP 연결 확인 중..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN --connect-timeout 10)
if [ "$HTTP_STATUS" = "301" ] || [ "$HTTP_STATUS" = "200" ]; then
    echo "✓ HTTP 연결 성공 (상태 코드: $HTTP_STATUS)"
else
    echo "✗ HTTP 연결 실패 (상태 코드: $HTTP_STATUS)"
fi
echo ""

# 3. HTTPS 연결 확인
echo "3. HTTPS 연결 확인 중..."
HTTPS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN --connect-timeout 10)
if [ "$HTTPS_STATUS" = "200" ]; then
    echo "✓ HTTPS 연결 성공 (상태 코드: $HTTPS_STATUS)"
else
    echo "✗ HTTPS 연결 실패 (상태 코드: $HTTPS_STATUS)"
fi
echo ""

# 4. SSL 인증서 정보 확인
echo "4. SSL 인증서 정보 확인 중..."
if command -v openssl &> /dev/null; then
    CERT_INFO=$(echo | openssl s_client -connect $DOMAIN:443 -servername $DOMAIN 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)
    if [ ! -z "$CERT_INFO" ]; then
        echo "✓ SSL 인증서 정보:"
        echo "$CERT_INFO"
    else
        echo "✗ SSL 인증서 정보 확인 실패"
    fi
else
    echo "⚠ openssl이 설치되지 않았습니다."
fi
echo ""

# 5. Let's Encrypt 인증서 상태 확인
echo "5. Let's Encrypt 인증서 상태 확인 중..."
if command -v certbot &> /dev/null; then
    CERTBOT_STATUS=$(sudo certbot certificates 2>/dev/null | grep -A 10 "$DOMAIN")
    if [ ! -z "$CERTBOT_STATUS" ]; then
        echo "✓ Let's Encrypt 인증서 정보:"
        echo "$CERTBOT_STATUS"
    else
        echo "✗ Let's Encrypt 인증서 정보 확인 실패"
    fi
else
    echo "⚠ certbot이 설치되지 않았습니다."
fi
echo ""

# 6. nginx 상태 확인
echo "6. nginx 서비스 상태 확인 중..."
NGINX_STATUS=$(sudo systemctl is-active nginx 2>/dev/null)
if [ "$NGINX_STATUS" = "active" ]; then
    echo "✓ nginx 서비스 실행 중"
else
    echo "✗ nginx 서비스 비활성 상태: $NGINX_STATUS"
fi
echo ""

# 7. 포트 확인
echo "7. 포트 상태 확인 중..."
PORT_80=$(sudo netstat -tlnp 2>/dev/null | grep ":80 " | wc -l)
PORT_443=$(sudo netstat -tlnp 2>/dev/null | grep ":443 " | wc -l)
PORT_3000=$(sudo netstat -tlnp 2>/dev/null | grep ":3000 " | wc -l)
PORT_4000=$(sudo netstat -tlnp 2>/dev/null | grep ":4000 " | wc -l)

echo "포트 80 (HTTP): $([ $PORT_80 -gt 0 ] && echo "✓ 열림" || echo "✗ 닫힘")"
echo "포트 443 (HTTPS): $([ $PORT_443 -gt 0 ] && echo "✓ 열림" || echo "✗ 닫힘")"
echo "포트 3000 (Frontend): $([ $PORT_3000 -gt 0 ] && echo "✓ 열림" || echo "✗ 닫힘")"
echo "포트 4000 (Backend): $([ $PORT_4000 -gt 0 ] && echo "✓ 열림" || echo "✗ 닫힘")"
echo ""

# 8. API 헬스체크
echo "8. API 헬스체크 중..."
API_HEALTH=$(curl -s https://$DOMAIN/api/health --connect-timeout 10 2>/dev/null)
if [ ! -z "$API_HEALTH" ]; then
    echo "✓ API 응답: $API_HEALTH"
else
    echo "✗ API 응답 없음"
fi
echo ""

echo "=== SSL 상태 확인 완료 ==="
echo "도메인: https://$DOMAIN"
echo "확인 완료 시간: $(date)" 