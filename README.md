# epics-docker

Build EPICS docker images for testing, development, training, and simulation.

## Quick Reference

Install the latest Linux bash shell scripts to start IOCs with custom
prefixes.  Replace any existing (v1.0) scripts with these new versions.

Suggestion: Place these shell scripts into a directory on the
executable `$PATH` and give each executable permission
(`chmod +x script_name`).  I create a `~/bin` directory for such scripts.

### custom synApps

Download:

```sh
cd ~/bin
wget https://raw.githubusercontent.com/prjemian/epics-docker/main/v1.1/n5_custom_synApps/start_xxx.sh
wget https://raw.githubusercontent.com/prjemian/epics-docker/main/v1.1/n5_custom_synApps/remove_container.sh
```

Example:  Create (or restart) 2 IOCs with prefixes `gp:` and `sky:`.  (Do
not specify the trailing `:`.  The script will manage that for you)

```sh
start_xxx.sh gp
start_xxx.sh sky
```

### custom Area Detector (ADSimDetector)

```sh
cd ~/bin
wget https://raw.githubusercontent.com/prjemian/epics-docker/main/v1.1/n6_custom_areaDetector/start_adsim.sh
wget https://raw.githubusercontent.com/prjemian/epics-docker/main/v1.1/n6_custom_areaDetector/remove_container.sh
```

Example:  Create (or restart) 2 IOCs with prefixes `ad:` and `adsky:`.  (Do
not specify the trailing `:`.  The script will manage that for you)

```sh
start_xxx.sh ad
start_xxx.sh adsky
```

### Hint

You _could_ create a new script to start all the IOCs you want.
Here's an example which starts all four IOCs above:

```bash
#!/bin/bash

start_xxx.sh gp
start_xxx.sh sky
start_xxx.sh ad
start_xxx.sh adsky
```

Save this into `~/bin/start_iocs.sh`, make it executable (`chmod +x ~/bin/start_iocs.sh`), then call it to start/restart the four IOCs:  `start_iocs.sh`

## Images Available

release | image | docs | notes
--- | --- | --- | ---
**v1.1** | [`prjemian/epics-base-7.0.5`](https://hub.docker.com/r/prjemian/epics-base-7.0.5/tags) | [docs](v1.1/n2_epics_base/README.md) | EPICS base 7.0.5 (built on Ubuntu 20.04.2 LTS)
**v1.1** | [`prjemian/synapps-6.2`](https://hub.docker.com/r/prjemian/synapps-6.2/tags) | [docs](v1.1/n3_synApps/README.md) | (stock) synApps 6.2
**v1.1** | [`prjemian/synapps-6.2-ad-3.10`](https://hub.docker.com/r/prjemian/synapps-6.2-ad-3.10/tags) | [docs](v1.1/n4_areaDetector/README.md) | (stock) area detector R3.10 (with updates from master branch)
**v1.1** | [`prjemian/custom-synapps-6.2`](https://hub.docker.com/r/prjemian/custom-synapps-6.2/tags) | [docs](v1.1/n5_custom_synApps/README.md) | customized XXX IOC with user-provided prefix
**v1.1** | [`prjemian/custom-synapps-6.2-ad-3.10`](https://hub.docker.com/r/prjemian/custom-synapps-6.2-ad-3.10/tags) | [docs](v1.1/n6_custom_areaDetector/README.md) | customized SimDetector IOC with user-provided prefix
---- | ---- | ---- | ----
**v1.0** | [`prjemian/epics-base-7.0.3`](https://hub.docker.com/r/prjemian/epics-base-7.0.3/tags) | [docs](v1.0/n2_epics_base/README.md) | EPICS base 7.0.3 (built on Ubuntu 18.04.3 LTS)
**v1.0** | [`prjemian/synApps-6.1`](https://hub.docker.com/r/prjemian/synapps-6.1/tags) | [docs](v1.0/n3_synApps/README.md) | synApps 6.1
**v1.0** | [`prjemian/synapps-6.1-ad-3.7`](https://hub.docker.com/r/prjemian/synapps-6.1-ad-3.7/tags) | [docs](v1.0/n4_areaDetector/README.md) | area detector 3.7

## Authors

* Pete Jemian

## Acknowledgements

* Contributors
  * Chen Zhang
  * Jeff Hoffman
  * Quan Zhou

* moved here from [virtualbeamline](https://github.com/prjemian/virtualbeamline),
  a fork of [KedoKudo/virtualbeamline](https://github.com/KedoKudo/virtualbeamline).
