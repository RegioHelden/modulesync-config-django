# RegioHelden's ModuleSync config for FOSS Django libraries

[ModuleSync](https://github.com/voxpupuli/modulesync) is used to keep configuration files of all of our different projects up to date and in sync.  
It works by compiling the [`.erb` templates](https://www.puppet.com/docs/puppet/5.5/lang_template_erb.html) in the `moduleroot` folder using variables from `config_defaults.yml` and project-specific ones from `.sync.yml` (in the respective project repository).  
A pull request is then be opened for each project in `managed_modules.yml` affected by these changes.

## Local dry run

To check which changes will be affecting our projects, you can dry run a comparison locally.

### Create a personal GitHub access token

To check out the code of the projects, you will need to set up a GitHub access token.  
Go to [GitHub user settings](https://github.com/settings/personal-access-tokens) and create a personal access token with the following settings:

* Token name: `RegioHelden ModuleSync`
* Resource owner: `RegioHelden`
* Expiration: as desired, ideally not without expiration
* Repository access: `Public repositories `

### Create a .env file in the root directory

```bash
GITHUB_TOKEN=<YOUR_TOKEN_FROM_ABOVE>
```

### Usage

To see the updates on the target projects that would result from your changes

```bash
docker compose up
```

## Per-project settings

Each project can have a `.sync.yml` file, which will overwrite settings from the global config (see `config_defaults.yml`)

An example `.sync.yml` file will look like this one

```yaml
---
:global:
  python_min_version: "3.11"
  module_rootname: "django_library"
  module_description: "This lib does awesome things to your Django app"
  module_keywords: ["django", "awesome"]

.devcontainer/devcontainer.json:
  run_services: ["app", "db"]
```

It's also possible to mark files as unmanaged in `.sync.yml`

```yaml
compose.yaml:
  unmanaged: true
```

## Required setup steps

### On manages repositories

Make sure branches are deleted after merge so that modulesync always starts clean

* As a repository admin
* Go to the repository settings
* Scroll down to the `Pull requests` section
* Check `Automatically delete head branches `

### On this modulesync repository

Set proper values for `GIT_AUTHOR_NAME`, `GIT_COMMITTER_NAME`, `GIT_AUTHOR_EMAIL` and `GIT_COMMITTER_EMAIL` in `.github/workflows/update.yaml`

* Use the username of the user that should open the modulesync MRs as `GIT_AUTHOR_NAME` and `GIT_COMMITTER_NAME`
* Use the anonymous committer email address of that user as `GIT_AUTHOR_EMAIL` and `GIT_COMMITTER_EMAIL`
  * As the user running modulesync
  * Click on your profile picture in the top right corner
  * Go to `Settings`
  * Under `Access` select `Emails`
  * Under `Primary email address`, your anonymous committer email is listed in the explanation text

Set up SSH key

* Create an SSH key
  * Run `ssh-keygen -t ed25519`
  * Don't set a passphrase
* Make the private part available as secret `MODULESYNC_SSH_PRIVATE_KEY` on this repository
  * As a repository admin
  * Go to repository settings
  * Under `Security`, open `Secrets and variables` and select `Actions`
  * Click `New repository secret`
  * Use `MODULESYNC_SSH_PRIVATE_KEY` as `Name`
  * Set the private part of the SSH key as `Secret`
* Add the public part as authentication key
  * As the user running modulesync
  * Click on your profile picture in the top right corner
  * Go to `Settings`
  * Go to `Developer Settings`
  * Under `Access`, select `SSH and GPG keys`
  * Click `New SSH key`
  * Use `ModuleSync commit key` as `Title`
  * Use `Authentication Key` as `Key type`
  * Set the public part of the SSH key as `Key`
* Add the public part as signing key
  * As the user running modulesync
  * Click on your profile picture in the top right corner
  * Go to `Settings`
  * Go to `Developer Settings`
  * Under `Access`, select `SSH and GPG keys`
  * Click `New SSH key`
  * Use `ModuleSync signing key` as `Title`
  * Use `Signing Key` as `Key type`
  * Set the public part of the SSH key as `Key`

Create a personal access token and make it available as secret `MODULESYNC_PERSONAL_ACCESS_TOKEN` on this repository

* Create the token
  * As the user running modulesync
  * Click on your profile picture in the top right corner
  * Go to `Settings`
  * Go to `Developer Settings`
  * Open `Personal acccess tokens` and select `Fine grained tokens`
  * Click `Generate new token`
  * Select the organization owning the managed repos as `Resource owner`
  * Select that the token never expires
  * Select `All repositories` for `Repository access`
  * Select the following `Repository permissions`
    * `Metadata` read only
    * `Pull requests` read and write
  * Copy that token!
* Make the token available
  * As a repository admin
  * Go to repository settings
  * Under `Security`, open `Secrets and variables` and select `Actions`
  * Click `New repository secret`
  * Use `MODULESYNC_PERSONAL_ACCESS_TOKEN` as `Name`
  * Set the just copied PAT as `Secret`

## Publish your changes

Commit the changes to a pull request on this repo.
The build pipeline will first do a dry run for the reviewer to be able to check the changes.

When this PR is merged into the main branch, another pipeline job will create the PRs on the target projects.

## ModuleSync Docs

See https://github.com/voxpupuli/modulesync for more details.
