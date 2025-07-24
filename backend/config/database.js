const { createClient } = require('@supabase/supabase-js');

console.log('🔧 [BACKEND] Initializing database connection...')

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_KEY;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

console.log('📊 [BACKEND] Environment variables check:')
console.log('🌐 SUPABASE_URL:', supabaseUrl ? 'SET' : 'MISSING')
console.log('🔑 SUPABASE_KEY:', process.env.SUPABASE_KEY ? 'SET' : 'MISSING')
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