#!/bin/bash

# =============================================================================
# 빠른 배포 스크립트
# =============================================================================
#
# 이 스크립트는 애플리케이션을 빠르게 배포합니다.
# 기본 nginx 테스트 페이지 대신 실제 애플리케이션을 실행합니다.
#
# 작성일: 2025-01-27
# =============================================================================

echo "🚀 빠른 배포를 시작합니다..."

# =============================================================================
# 1. 현재 디렉토리 확인
# =============================================================================
echo "📁 현재 디렉토리: $(pwd)"

# =============================================================================
# 2. 백엔드 배포
# =============================================================================
echo "🔧 백엔드를 배포합니다..."

if [ -d "backend" ]; then
    cd backend
    
    # 의존성 설치
    echo "📦 백엔드 의존성을 설치합니다..."
    npm install
    
    # PM2로 백엔드 시작
    echo "🚀 백엔드 서버를 시작합니다..."
    pm2 delete backend 2>/dev/null || true
    pm2 start index.js --name backend --watch
    
    cd ..
    echo "✅ 백엔드 배포 완료"
else
    echo "❌ backend 디렉토리를 찾을 수 없습니다"
    exit 1
fi

# =============================================================================
# 3. 프론트엔드 배포
# =============================================================================
echo "🔧 프론트엔드를 배포합니다..."

if [ -d "frontend" ]; then
    cd frontend
    
    # 의존성 설치
    echo "📦 프론트엔드 의존성을 설치합니다..."
    npm install
    
    # 프로덕션 빌드
    echo "🏗️ 프론트엔드를 빌드합니다..."
    npm run build
    
    # PM2로 프론트엔드 시작
    echo "🚀 프론트엔드 서버를 시작합니다..."
    pm2 delete frontend 2>/dev/null || true
    pm2 start npm --name frontend -- run preview
    
    cd ..
    echo "✅ 프론트엔드 배포 완료"
else
    echo "❌ frontend 디렉토리를 찾을 수 없습니다"
    exit 1
fi

# =============================================================================
# 4. nginx 설정 적용
# =============================================================================
echo "🌐 nginx 설정을 적용합니다..."

if [ -f "nginx.conf" ]; then
    # nginx 설정 파일 복사
    sudo cp nginx.conf /etc/nginx/nginx.conf
    
    # nginx 설정 테스트
    echo "🔍 nginx 설정을 테스트합니다..."
    if sudo nginx -t; then
        echo "✅ nginx 설정이 유효합니다."
        
        # nginx 재시작
        echo "🔄 nginx를 재시작합니다..."
        sudo systemctl restart nginx
        
        # nginx 상태 확인
        if sudo systemctl is-active --quiet nginx; then
            echo "✅ nginx가 정상적으로 실행 중입니다."
        else
            echo "❌ nginx 시작에 실패했습니다."
            exit 1
        fi
    else
        echo "❌ nginx 설정에 오류가 있습니다."
        exit 1
    fi
else
    echo "❌ nginx.conf 파일을 찾을 수 없습니다"
    exit 1
fi

# =============================================================================
# 5. 배포 완료 확인
# =============================================================================
echo ""
echo "🎉 빠른 배포가 완료되었습니다!"
echo ""
echo "📋 배포 정보:"
echo "   🌐 웹사이트: https://invenone.it.kr"
echo "   🔗 API 서버: https://invenone.it.kr/api"
echo "   📊 헬스체크: https://invenone.it.kr/api/health"
echo ""
echo "🔧 확인 명령어:"
echo "   PM2 상태: pm2 status"
echo "   nginx 상태: sudo systemctl status nginx"
echo "   포트 확인: sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'"
echo ""

# PM2 상태 출력
echo "📊 현재 PM2 프로세스 상태:"
pm2 status

echo ""
echo "✅ 배포가 완료되었습니다. 브라우저에서 https://invenone.it.kr 을 확인해보세요!" 