# infrastructure

Very important, read first: https://fattist.atlassian.net/wiki/spaces/OSS/pages/112295937/AWS+MFA+setup+for+development


## Setup

The following script is not often managed nor kept up. If you run into problems, please commit updates containing fix(es).

```
./scripts/infrastructure.sh
```

## Chores

```
tfenv use
nvm use
npm i
```

## Use

If you haven't read the Confluence document on how to run TF with MFA, the following will not work.

If you're using more than one version of TF locally, always be sure to use the `.terraform-version` defined within the repo. You will not be allowed to execute TF on this project with any other version.

```
aws-vault exec <profile-name> -- npx grunt terraform --env=<environment>
```

## Notes

Please, do not update TF versioning for the repo. It will cripple multiple machines if not done properly. Reach out to @listenrightmeow for updates.