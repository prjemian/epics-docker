# README.md

The `prjemian/os_only` image provides the base operating
system used to build EPICS software in docker images.
Tools for compiling EPICS software including compilers and
screen-oriented text editors (nano, vim, and vi) are included.
The screen program is also included for running detached console
sessions such as IOCs.

- [README.md](#readmemd)
  - [This Docker Image Provides ...](#this-docker-image-provides-)
  - [Environment variables](#environment-variables)
  - [Docker images used by this image](#docker-images-used-by-this-image)

By default, no application is run.
This image is not uploaded.
It is built locally for building epics_base.

* docker source: `ubuntu:latest` (built: 2021-02)

    (base) builder@host:~/.../epics-docker/n1_os_only$ docker run prjemian/os_only-1.1 uname -a
    Linux 85c8aa509756 4.4.0-187-generic #217-Ubuntu SMP Tue Jul 21 04:18:15 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux

    (base) builder@host:~/.../epics-docker/n1_os_only$ docker run prjemian/os_only cat /etc/os-release
    NAME="Ubuntu"
    VERSION="20.04.1 LTS (Focal Fossa)"
    ID=ubuntu
    ID_LIKE=debian
    PRETTY_NAME="Ubuntu 20.04.1 LTS"
    VERSION_ID="20.04"
    HOME_URL="https://www.ubuntu.com/"
    SUPPORT_URL="https://help.ubuntu.com/"
    BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
    PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
    VERSION_CODENAME=focal
    UBUNTU_CODENAME=focal

## This Docker Image Provides ...

A Linux operating system for running [EPICS](https://epics.anl.gov)
software such as server IOCs in docker containers.

## Environment variables

These environment variables were defined when creating this docker image
(from `grep ENV Dockerfile`):

    ENV APP_ROOT="/opt"
    ENV EDITOR="nano"
    ENV PROMPT_DIRTRIM=3

## Docker images used by this image

These are the docker images from which this image is based:

from | image | description
--- | --- | ---
dockerhub | `ubuntu` | Ubuntu 20.04.1 LTS (at the time of the build)
