const cwd = process.cwd();

module.exports = grunt => {
  grunt.registerTask('deploy', function() {
    const ref = grunt.option('CI_COMMIT_REF');
    const config = grunt.file.readYAML(`${cwd}/secrets/terraform/${grunt.config.get('environment')}.yml`);
    const output = grunt.file.readJSON(`${cwd}/terraform/${config.region}.${grunt.config.get('environment')}.json`);

    if (!ref) {
      grunt.fail.fatal('Grunt: Missing CI_COMMIT_REF');
    } else {
      grunt.config.set('config', config);
      grunt.config.set('output', output);
      grunt.config.set('dest', grunt.config.get('environment') === 'development' ? '' : `${ref}/`);
      grunt.config.set('originPath', grunt.config.get('environment') === 'development' ? '/' : `/${ref}`);
    }
  });
}
