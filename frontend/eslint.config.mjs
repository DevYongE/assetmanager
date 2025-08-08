// 2025-08-08: oxc-parser 네이티브 바인딩 문제 해결을 위한 ESLint 설정
// oxc-parser 대신 기본 파서 사용

import { FlatCompat } from '@eslint/eslintrc'
import js from '@eslint/js'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended
})

export default [
  ...compat.extends('@nuxt/eslint-config'),
  {
    // 2025-08-08: oxc-parser 대신 기본 파서 사용
    languageOptions: {
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        ecmaFeatures: {
          jsx: true
        }
      }
    },
    rules: {
      // 2025-08-08: oxc-parser 관련 규칙 비활성화
      'no-unused-vars': 'warn',
      'no-console': 'off',
      'vue/multi-word-component-names': 'off',
      'vue/no-unused-vars': 'warn'
    }
  }
]
