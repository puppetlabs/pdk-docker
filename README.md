# Puppet Development Kit (PDK) Docker Images

[![Code Owners](https://img.shields.io/badge/owners-DevX--team-blue)](https://github.com/puppetlabs/pdk-docker/blob/main/CODEOWNERS)
![ci](https://github.com/puppetlabs/pdk-docker/actions/workflows/image-push.yml/badge.svg)

This repository provides official docker images for the Puppet Development Kit (PDK).

Images are published to Docker Hub at [https://hub.docker.com/r/puppet/pdk](https://hub.docker.com/r/puppet/pdk).

The following image tags are available from Docker Hub:

 - `latest`: Meta-tag which will always point to the latest stable PDK release
 - `nightly`: Meta-tag which will always point to the latest PDK release which may
 be a pre-release build

Additionally there are version-specific tags for every PDK release that makes it on
to [http://nightlies.puppet.com/](http://nightlies.puppet.com/), for example `1.12.0.0` (stable release),
`1.13.0.0.pre.2.g9c61983` (nightly pre-release).

To learn more about the PDK, visit [https://puppet.com/docs/pdk/latest/pdk.html](https://puppet.com/docs/pdk/latest/pdk.html)
and [https://github.com/puppetlabs/pdk](https://github.com/puppetlabs/pdk).

## How images are built

The PDK docker images are currently based on a fairly minimal Ubuntu 22.04 image.
From there, a PDK `.deb` package is installed. Since there is a lag time between
when changes are merged to the `puppetlabs/pdk` or `puppetlabs/pdk-vanagon`
Github repositories and when a `.deb` package with the changes is actually available,
we can't trigger Docker Hub builds immediately on commit/tag to either of those
repositories.

Instead, we have configured a [periodic Jenkins job](https://jenkins-platform.delivery.puppetlabs.net/view/PDK/view/main/) (internal only right now, sorry)
which runs the `update-pdk-release-file.rb` script in this repo and then checks to see
if that resulted in any changes to the `pdk-release.env` file. This file contains
environment variables which indicate what the most recent PDK release package available
on the  [Puppet nightlies](http://nightlies.puppet.com/apt/pool/bionic/puppet/p/pdk/)
server is. `pdk-release.env` is then used by the `Dockerfile` (via `install-pdk-release.sh`)
to build an image containing the specified release package.

If changes to `pdk-release.env` are detected by the Jenkins job, a new commit is
made to the `main` branch of this repo. (If the release is identified as a final
release, the `stable` branch is rebased on `main` to pick up this change as well.)
Lastly a new tag is made with the version number of the new release and then Jenkins
pushes all commits and tags back to this repo.

Finally, Docker Hub is configured to watch the this repo and build/tag new images
automatically based on the branch or tag that received new commits.

## How to use the Image

Download a release from Docker Hub as detailed above. e.g.

```bash
docker pull puppet/pdk:latest
```

Run it

```bash
docker run -v /path/to/module:/workspace puppet/pdk <pdk command>
```

Run it with persistent pdk cache

```bash
docker run -v /path/to/module:/workspace -v /path/to/cache:/cache puppet/pdk <pdk command>
```
