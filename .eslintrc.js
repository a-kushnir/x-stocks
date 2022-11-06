module.exports = {
  root: true,
  env: {
    browser: true,
    node: true,
    es6: true,
  },
  extends: ['plugin:prettier/recommended', 'eslint:recommended', 'prettier'],
  parser: '@babel/eslint-parser',
  parserOptions: {
    ecmaVersion: 7,
  },
  rules: {
    'prettier/prettier': ['error', { singleQuote: true }],
    'no-unused-vars': ['error', { argsIgnorePattern: '^_' }]
  },
  ignorePatterns: ['**/vendor/**/*.js'],
  overrides: [
    {
      files: ['**/*.spec.js'],
      env: {
        jest: true,
      },
    },
  ],
  globals: {
    Turbo: 'readonly',
  },
};
