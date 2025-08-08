// 2025-08-08: 환경변수 로드 추가 (dotenv 설정이 먼저 실행되도록)
require('dotenv').config();

const { createClient } = require('@supabase/supabase-js');

console.log('🔧 [BACKEND] Initializing database connection...')

// 2025-08-08: SUPABASE_KEY → SUPABASE_ANON_KEY 변수명 정규화 (README, 프론트와 일치) 
//             배포 시 환경변수 혼선을 방지합니다.
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY; // 2025-08-08: 수정
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

console.log('📊 [BACKEND] Environment variables check:')
console.log('🌐 SUPABASE_URL:', supabaseUrl ? 'SET' : 'MISSING')
// 2025-08-08: 로그 키명도 SUPABASE_ANON_KEY로 통일
console.log('🔑 SUPABASE_ANON_KEY:', process.env.SUPABASE_ANON_KEY ? 'SET' : 'MISSING')
console.log('🔑 SUPABASE_SERVICE_ROLE_KEY:', supabaseServiceRoleKey ? 'SET' : 'MISSING')

if (!supabaseUrl || !supabaseAnonKey) {
  console.log('❌ [BACKEND] Missing Supabase environment variables')
  throw new Error('Missing Supabase environment variables');
}

console.log('✅ [BACKEND] Database environment variables are set')

// Client for user operations (with RLS)
const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Admin client for service operations (bypasses RLS)
const supabaseAdmin = createClient(supabaseUrl, supabaseServiceRoleKey);

module.exports = {
  supabase,
  supabaseAdmin
};