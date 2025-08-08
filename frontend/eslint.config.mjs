// 2025-08-08: oxc-parser 완전 우회를 위한 최소 ESLint 설정
// oxc-parser나 다른 네이티브 바인딩 의존성 없이 작동

export default [
  {
    // 모든 파일에 적용
    files: ['**/*.{js,ts,vue}'],
    languageOptions: {
      // 기본 파서만 사용 (oxc-parser 완전 우회)
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module'
      }
    },
    rules: {
      // 최소한의 기본 규칙만 적용
      'no-unused-vars': 'warn',
      'no-console': 'off',
      'no-undef': 'error',
      'no-redeclare': 'error'
    }
  }
]
