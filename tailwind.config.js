const plugin = require('tailwindcss/plugin');
const glob = require('glob');
const path = require('path');

module.exports = {
  content: [
    './app/javascript/**/*.*',
    './app/components/**/*.{js,css,scss,rb,erb}',
    './lib/action_view/helpers/*.rb',
    ...glob.sync('app/views').map((dir) => path.join(dir, '**/*.erb')),
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/line-clamp'),
    plugin(function ({ _, addVariant, e }) {
      ['js', 'no-js', 'rails-dev'].forEach((variant) => {
        addVariant(variant, ({ modifySelectors, separator }) => {
          modifySelectors(function ({ className }) {
            return `.${variant} .${e(`${variant}${separator}${className}`)}`;
          });
        });
      });
    }),
  ]
}
