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

## Publish your changes

Commit the changes to a pull request on this repo.
The build pipeline will first do a dry run for the reviewer to be able to check the changes.

When this PR is merged into the main branch, another pipeline job will create the PRs on the target projects.

## ModuleSync Docs

See https://github.com/voxpupuli/modulesync for more details.
