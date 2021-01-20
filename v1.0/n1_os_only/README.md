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

* docker source: `ubuntu:latest` (Ubuntu 18.04)

    root@20316c4f9135:/home# uname -a
    Linux 20316c4f9135 4.15.0-64-generic #73-Ubuntu SMP Thu Sep 12 13:16:13 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
