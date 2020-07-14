const cwd = process.cwd();

module.exports = grunt => {
  grunt.registerTask('tf', function() {
    const conf = grunt.file.readYAML(`${cwd}/secrets/terraform/${grunt.config.get('environment')}.yml`);

    if (!conf.region) {
      grunt.fail.fatal('Grunt: Missing region');
    } else {
      grunt.config.set('region', conf.region);
    }
  });
}
