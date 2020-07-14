const cwd = process.cwd();
const grunt = require('grunt');

const tfvars = `${cwd}/output/tfvars/variables.tfvars`;

const local = (opts) => (`AWS_PROFILE=${opts.profile} \
  AWS_DEFAULT_REGION=${opts.region}`);

module.exports = {
  'terraform-apply': {
    command: () => {
      const conf = grunt.file.readYAML(`${cwd}/secrets/terraform/${grunt.config.get('environment')}.yml`);
      let cmd = `${local(conf)} terraform apply -var-file=${tfvars}`;

      if (grunt.option('ci')) {
        cmd = `${cmd} -auto-approve -input=false`;
      }

      return cmd;
    },
    options: {
      execOptions: {
        cwd: `${cwd}/terraform`
      }
    }
  },
  'terraform-destroy': {
    command: () => {
      const conf = grunt.file.readYAML(`${cwd}/secrets/terraform/${grunt.config.get('environment')}.yml`);
      let cmd = `${local(conf)} terraform destroy -var-file=${tfvars}`;

      if (grunt.option('ci')) {
        cmd = `${cmd} -auto-approve -input=false`;
      }

      return cmd;
    },
    options: {
      execOptions: {
        cwd: `${cwd}/terraform`
      }
    }
  },
  'terraform-init': {
    command:() => {
      const backend = grunt.file.readYAML(`${cwd}/secrets/terraform/backend.yml`);
      const conf = grunt.file.readYAML(`${cwd}/secrets/terraform/${grunt.config.get('environment')}.yml`);
      let cmd = `${local(conf)}\
        terraform init\
        -backend-config="profile=${backend.profile}" \
        -backend-config=bucket=${backend.bucket}\
        -backend-config=key=${backend.key}\
        -backend-config=region=${backend.region}\
        -backend-config=dynamodb_table=${backend.table}`;

      if (grunt.option('ci')) {
        cmd = `${cmd} -input=false`;
      }

      return cmd;
    },
    options: {
      execOptions: {
        cwd: `${cwd}/terraform`
      }
    }
  },
  'terraform-output': {
    command: () => {
      const conf = grunt.file.readYAML(`${cwd}/secrets/terraform/${grunt.config.get('environment')}.yml`);
      const path = grunt.option('CI_PROJECT_DIR')
        ? `${grunt.option('CI_PROJECT_DIR')}/terraform/${conf.region}.${grunt.config.get('environment')}.json`
        : `${cwd}/terraform/output/${conf.region}.${grunt.config.get('environment')}.json`;

      return `${local(conf)} terraform output -json > ${path}`;
    },
    options: {
      execOptions: {
        cwd: `${cwd}/terraform`
      }
    }
  },
  'terraform-plan': {
    command: () => {
      const conf = grunt.file.readYAML(`${cwd}/secrets/terraform/${grunt.config.get('environment')}.yml`);
      return `${local(conf)} terraform plan -var-file=${tfvars}`;
    },
    options: {
      execOptions: {
        cwd: `${cwd}/terraform`
      }
    }
  },
  'terraform-refresh': {
    command: () => {
      const conf = grunt.file.readYAML(`${cwd}/secrets/terraform/${grunt.config.get('environment')}.yml`);
      return `${local(conf)} terraform refresh -var-file=${tfvars}`;
    },
    options: {
      execOptions: {
        cwd: `${cwd}/terraform`
      }
    }
  },
  'terraform-validate': {
    command: () => {
      const conf = grunt.file.readYAML(`${cwd}/secrets/terraform/${grunt.config.get('environment')}.yml`);
      return `${local(conf)} terraform validate`;
    },
    options: {
      execOptions: {
        cwd: `${cwd}/terraform`
      }
    }
  },
  'terraform-workspace': {
    command: () => {
      const conf = grunt.file.readYAML(`${cwd}/secrets/terraform/${grunt.config.get('environment')}.yml`);
      return `${local(conf)} terraform workspace select ${grunt.config.get('environment')}`;
    },
    options: {
      execOptions: {
        cwd: `${cwd}/terraform`
      }
    }
  },
  'terraform-adhoc': {
    command: () => {
      const conf = grunt.file.readYAML(`${cwd}/secrets/terraform/${grunt.config.get('environment')}.yml`);
      return `${local(conf)} terraform workspace new development`;
    },
    options: {
      execOptions: {
        cwd: `${cwd}/terraform`
      }
    }
  }
};
