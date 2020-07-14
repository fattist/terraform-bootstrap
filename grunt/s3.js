module.exports = grunt => ({
  config: grunt.config.get('config'),
  output: grunt.config.get('output'),
  dest: grunt.config.get('dest'),
  options: {
    accessKeyId: "<%= config.terraform.id %>",
    secretAccessKey: "<%= config.terraform.key %>",
    bucket: "<%= output['s3-dashboard-public-bucket-name'].value %>",
    region: "<%= config.region %>"
  },
  dashboard: {
    cwd: '../build/',
    src: '**',
    dest: "<%= dest %>"
  }
})
