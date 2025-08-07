#!/bin/bash

# =============================================================================
# 정적 파일 문제 진단 스크립트
# =============================================================================
#
# 이 스크립트는 Nginx에서 정적 파일들이 제대로 서빙되지 않는
# 문제를 정확히 진단합니다.
#
# 작성일: 2025-01-27
# =============================================================================

echo "🔍 정적 파일 문제를 진단합니다..."
echo ""

# =============================================================================
# 1. 현재 디렉토리 확인
# =============================================================================
echo "📋 1단계: 현재 디렉토리 확인"

echo "현재 디렉토리:"
pwd

echo ""
echo "프로젝트 구조 확인:"
ls -la

echo ""

# =============================================================================
# 2. 프론트엔드 빌드 파일 확인
# =============================================================================
echo "🔨 2단계: 프론트엔드 빌드 파일 확인"

echo "프론트엔드 디렉토리 확인:"
if [ -d "frontend" ]; then
    echo "✅ frontend 디렉토리 존재"
    cd frontend
    echo "현재 디렉토리: $(pwd)"
    
    echo ""
    echo ".output 디렉토리 확인:"
    if [ -d ".output" ]; then
        echo "✅ .output 디렉토리 존재"
        ls -la .output/
        
        echo ""
        echo ".output/public 디렉토리 확인:"
        if [ -d ".output/public" ]; then
            echo "✅ .output/public 디렉토리 존재"
            ls -la .output/public/
            
            echo ""
            echo "_nuxt 디렉토리 확인:"
            if [ -d ".output/public/_nuxt" ]; then
                echo "✅ _nuxt 디렉토리 존재"
                echo "_nuxt 파일 목록:"
                ls -la .output/public/_nuxt/ | head -10
                
                echo ""
                echo "특정 파일 존재 확인:"
                for file in DlAUqK2U.js ncEYqr56.js CmpikdwT.js BU7s9tN_.js sdLDN5q1.js; do
                    if [ -f ".output/public/_nuxt/$file" ]; then
                        echo "✅ $file 존재"
                    else
                        echo "❌ $file 없음"
                    fi
                done
            else
                echo "❌ _nuxt 디렉토리 없음"
            fi
        else
            echo "❌ .output/public 디렉토리 없음"
        fi
    else
        echo "❌ .output 디렉토리 없음"
    fi
    
    cd ..
else
    echo "❌ frontend 디렉토리 없음"
fi

echo ""

# =============================================================================
# 3. PM2 상태 확인
# =============================================================================
echo "⚙️ 3단계: PM2 상태 확인"

echo "PM2 상태:"
pm2 status

echo ""
echo "프론트엔드 프로세스 상세 정보:"
pm2 show qr-frontend 2>/dev/null || echo "❌ qr-frontend 프로세스 없음"

echo ""

# =============================================================================
# 4. 포트 상태 확인
# =============================================================================
echo "🔌 4단계: 포트 상태 확인"

echo "포트 3000 상태:"
sudo netstat -tlnp | grep :3000 || echo "❌ 포트 3000에서 실행 중인 프로세스 없음"

echo ""
echo "포트 4000 상태:"
sudo netstat -tlnp | grep :4000 || echo "❌ 포트 4000에서 실행 중인 프로세스 없음"

echo ""

# =============================================================================
# 5. 프론트엔드 직접 테스트
# =============================================================================
echo "🧪 5단계: 프론트엔드 직접 테스트"

echo "프론트엔드 서버 테스트:"
curl -I http://localhost:3000 2>/dev/null && echo "✅ 프론트엔드 서버 정상" || echo "❌ 프론트엔드 서버 실패"

echo ""
echo "프론트엔드 _nuxt 경로 테스트:"
curl -I http://localhost:3000/_nuxt/ 2>/dev/null && echo "✅ 프론트엔드 _nuxt 경로 정상" || echo "❌ 프론트엔드 _nuxt 경로 실패"

echo ""
echo "특정 JS 파일 테스트:"
curl -I http://localhost:3000/_nuxt/DlAUqK2U.js 2>/dev/null && echo "✅ DlAUqK2U.js 정상" || echo "❌ DlAUqK2U.js 실패"

echo ""

# =============================================================================
# 6. Nginx 설정 확인
# =============================================================================
echo "🌐 6단계: Nginx 설정 확인"

echo "현재 Nginx 설정:"
sudo cat /etc/nginx/conf.d/assetmanager.conf | grep -A 10 "_nuxt"

echo ""
echo "Nginx 설정 테스트:"
sudo nginx -t

echo ""
echo "Nginx 상태:"
sudo systemctl status nginx --no-pager

echo ""

# =============================================================================
# 7. Nginx 로그 확인
# =============================================================================
echo "📝 7단계: Nginx 로그 확인"

echo "최근 Nginx 오류 로그:"
sudo tail -5 /var/log/nginx/error.log

echo ""
echo "최근 Nginx 액세스 로그:"
sudo tail -5 /var/log/nginx/access.log

echo ""

# =============================================================================
# 8. 문제 해결 제안
# =============================================================================
echo "🛠️ 8단계: 문제 해결 제안"

echo "현재 상황 분석:"
if [ -d "frontend/.output/public/_nuxt" ]; then
    echo "✅ 빌드 파일 존재"
    if curl -I http://localhost:3000/_nuxt/ >/dev/null 2>&1; then
        echo "✅ 프론트엔드에서 정적 파일 서빙 정상"
        echo "❌ Nginx 프록시 설정 문제"
        echo ""
        echo "해결 방법:"
        echo "1. Nginx 설정 재적용"
        echo "2. Nginx 재시작"
        echo "3. 브라우저 캐시 삭제"
    else
        echo "❌ 프론트엔드에서 정적 파일 서빙 실패"
        echo ""
        echo "해결 방법:"
        echo "1. 프론트엔드 재빌드"
        echo "2. PM2 재시작"
    fi
else
    echo "❌ 빌드 파일 없음"
    echo ""
    echo "해결 방법:"
    echo "1. 프론트엔드 재빌드"
    echo "2. PM2 재시작"
fi

echo ""

# =============================================================================
# 9. 완료
# =============================================================================
echo "🎉 정적 파일 문제 진단 완료!"
echo ""
echo "📋 다음 단계:"
echo "   1. 위 결과를 확인하여 문제점 파악"
echo "   2. 필요한 해결 방법 실행"
echo "   3. 브라우저에서 재테스트"
echo ""
echo "✅ 진단이 완료되었습니다!" 