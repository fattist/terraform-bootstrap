const cwd = process.cwd();
const fs = require('fs');
const spawn = require('child_process').spawnSync;

module.exports = grunt => {
  const vault = (opts) => {
    return new Promise((resolve, reject) => {
      const files = grunt.file.expand({ cwd: `${cwd}/${opts.path}` }, opts.glob);

      grunt.log.ok(files);
      files.forEach((file, idx) => {
        fs.lstat(file, (err, stats) => {
          let cmd = `ansible-vault ${opts.cmd} ${cwd}/vault/${file} --vault-password-file ${cwd}/secrets/vault-pass.txt`;
          cmd = opts.cmd === 'view' ?  `${cmd} > ${cwd}/secrets/${file}` : cmd;

          grunt.file.mkdir(`${cwd}/secrets/${file}`.replace(/\/([.\w])+$/, ''));
          spawn(cmd, [], { cwd:`${cwd}/vault`, shell: true, stdio: 'inherit' });

          if (idx === files.length - 1) {
            resolve();
          }
        });
      });
    });
  }

  grunt.registerMultiTask('vault', 'Ansible Vault', async function() {
    const done = this.async();

    try {
      await vault({
        cmd: this.data.cmd,
        path: this.data.path,
        glob: this.data.glob
      });
    } catch (error) {
      grunt.fail.fatal(`Grunt: ${error}`);
    }

    done();
  });
}
