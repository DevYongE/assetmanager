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
    
    // Redirect to login for protected routes
    return navigateTo('/login')
  }
  
  // Redirect authenticated users away from auth pages
  const authRoutes = ['/login', '/register']
  if (authRoutes.includes(to.path)) {
    return navigateTo('/dashboard')
  }
}) 