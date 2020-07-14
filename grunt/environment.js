const cwd = process.cwd();

module.exports = grunt => {
  grunt.registerTask('environment', function() {
    let environment = grunt.option('env') || 'local';

    environment = /^(stag)(e|ing)/.test(environment)
      ? 'staging'
      : /^(prod)(uction)?/.test(environment)
        ? 'production'
        : /^(dev)(elopment)?/.test(environment)
          ? 'development'
          : /^(test)(ing)?/.test(environment)
            ? 'test'
            : /^(local)/.test(environment)
              ? 'local'
                : /^(global)/.test(environment)
                  ? 'global' : null;


    if (!environment) {
      grunt.fail.fatal('Grunt: Environment unknown');
    }

    grunt.log.oklns(environment);
    grunt.config.set('environment', environment);
  });
};
