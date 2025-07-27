@echo off
REM 2025-07-27: Windows 환경 개발 서버 실행 스크립트

echo 🚀 Starting development server on Windows...

REM 환경변수 설정 (개발 환경)
set NODE_ENV=development
set API_BASE_URL=http://localhost:4000

echo 📦 Installing dependencies...
cd frontend
npm install

echo 🚀 Starting development server...
npm run dev:win

pause 