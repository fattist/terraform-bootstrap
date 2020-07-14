const cwd = process.cwd();

module.exports = grunt => {
  const variables = (opts) => {
    const env = grunt.config.get('environment');
    const helper = require(`${cwd}/grunt/helpers/template.js`);
    const tpl = grunt.option('tpl') || 'tfvars';

    let secretsPath = `${cwd}/secrets/terraform/${env}.yml`;
    let variablesPath = `${cwd}/output/tfvars/variables.tfvars`;

    if (opts.filename) {
      secretsPath = `${cwd}/secrets/terraform/${opts.filename}.yml`;
      variablesPath = `${cwd}/output/tfvars/${opts.filename}.tfvars`;
    }

    helper.conf(grunt.file.readYAML(secretsPath));
    helper.create(tpl, variablesPath);
  }

  grunt.registerMultiTask('variables', 'Terraform Variables', function () {
    try {
      variables({
        filename: this.data.filename
      });
    } catch (error) {
      grunt.fail.fatal(`Grunt: ${error}`);
    }
  });
}
