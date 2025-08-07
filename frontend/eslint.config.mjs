// @ts-check
// 2025-01-27: ESLint 설정 수정 - .nuxt 파일이 없을 때 처리
try {
  const withNuxt = await import('./.nuxt/eslint.config.mjs')
  export default withNuxt.default(
    // Your custom configs here
  )
} catch (error) {
  // .nuxt 파일이 없을 때 기본 설정 사용
  export default [
    {
      files: ['**/*.{js,ts,vue}'],
      rules: {
        // 기본 규칙들
      }
    }
  ]
}
