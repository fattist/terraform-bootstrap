module.exports = grunt => ({
  config: grunt.config.get('config'),
  output: grunt.config.get('output'),
  originPath: grunt.config.get('originPath'),
  options: {
    accessKeyId: "<%= config.terraform.id %>",
    secretAccessKey: "<%= config.terraform.key %>",
    distributionId: "<%= output['cloudfront-dashboard-id'].value %>"
  },
  dashboard: {
    options: {
      invalidations: ['/*'],
      originPath: "<%= originPath %>"
    }
  }
})
