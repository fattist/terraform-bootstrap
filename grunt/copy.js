module.exports = (grunt, options) => ({
  backend: {
    environment: grunt.config.get('environment'),
    expand: true,
    cwd: 'secrets',
    src: ['**/<%= environment %>.yml', '!terraform/*'],
    dest: '',
    rename: (dest, src) => (`../${src.replace(/[/]([.\w]+)$/, '')}/src/main/resources/application.yml`)
  },
  dashboard: {
    environment: grunt.config.get('environment'),
    expand: true,
    cwd: 'secrets',
    src: ['client-dashboard/env.<%= environment %>'],
    dest: '',
    rename: (dest, src) => ('../.env')
  },
  keys: {
    expand: true,
    cwd: 'secrets',
    src: [
      'terraform/keys/**/*'
    ],
    dest: 'vault/',
  },
  terraform: {
    environment: grunt.config.get('environment'),
    region: grunt.config.get('region'),
    expand: true,
    cwd: 'terraform',
    src: 'zones/<%= region %>/<%= environment %>.tf',
    dest: '',
    rename: (dest, src) => ('terraform/main.tf')
  },
  vault: {
    expand: true,
    cwd: 'secrets',
    src: [
      '**/env.*',
      '**/*.pem',
      '**/*.properties',
      '**/*.pub',
      '**/*.yml'
    ],
    dest: 'vault/',
  }
})
