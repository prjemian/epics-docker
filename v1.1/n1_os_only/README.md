# README.md

The `prjemian/os_only` image provides the base operating
system used to build EPICS software in docker images.
Tools for compiling EPICS software including compilers and
screen-oriented text editors (nano, vim, and vi) are included.
The screen program is also included for running detached console
sessions such as IOCs.

By default, no application is run.
This image is not uploaded.  
It is built locally for building epics_base.

* docker source: `ubuntu:latest` (Ubuntu 20.04)

    (base) builder@host:~/.../epics-docker/n1_os_only$ docker run prjemian/os_only uname -a
    Linux e8eaab1b99c5 5.3.0-51-generic #44~18.04.2-Ubuntu SMP Thu Apr 23 14:27:18 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
    (base) builder@host:~/.../epics-docker/n1_os_only$ docker run prjemian/os_only cat /etc/os-release 
    NAME="Ubuntu"
    VERSION="20.04 LTS (Focal Fossa)"
    ID=ubuntu
    ID_LIKE=debian
    PRETTY_NAME="Ubuntu 20.04 LTS"
    VERSION_ID="20.04"
    HOME_URL="https://www.ubuntu.com/"
    SUPPORT_URL="https://help.ubuntu.com/"
    BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
    PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
    VERSION_CODENAME=focal
    UBUNTU_CODENAME=focal