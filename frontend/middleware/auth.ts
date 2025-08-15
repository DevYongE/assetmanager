export default defineNuxtRouteMiddleware((to, from) => {
  const authStore = useAuthStore()
  
  // Skip middleware on server
  if (import.meta.server) return
  
  // Check if user is authenticated
  if (!authStore.isAuthenticated) {
    // Allow access to public routes
    const publicRoutes = ['/', '/login', '/register']
    if (publicRoutes.includes(to.path)) {
      return
    }
    
    // 2025-01-27: QR 링크 접속 시 원래 URL 저장 후 로그인 페이지로 리다이렉트
    if (process.client) {
      // QR 관련 페이지인지 확인
      const isQRPage = to.path.includes('/qr-') || to.path.includes('/devices/') || to.path.includes('/employees/')
      
      if (isQRPage) {
        console.log('🔐 [AUTH MIDDLEWARE] QR page access detected, saving URL:', to.fullPath)
        sessionStorage.setItem('redirect_after_login', to.fullPath)
      }
    }
    
    // Redirect to login for protected routes
    return navigateTo('/login')
  }
  
  // Redirect authenticated users away from auth pages
  const authRoutes = ['/login', '/register']
  if (authRoutes.includes(to.path)) {
    return navigateTo('/dashboard')
  }
}) 