module.exports = {
  dashboard: {
    src: ['../build', '../.env', '../.env.*'],
    options: {
      force: true,
    }
  },
  terraform: ['terraform/main.tf'],
  vault: ['vault'],
  terraformsecrets: ['terraform/secrets']
};
