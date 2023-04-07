# IOC Manager Script

`iocmgr.sh` is the IOC manager shell script.

Install the latest [`iocmgr.sh`](v2.0/docs/iocmgr.md) (Linux bash shell script
to manage IOCs with custom prefixes).  Replace any existing (v1.0) scripts with
this single (new) version.

Suggestion: Place `iocmgr.sh` into a directory on the executable `$PATH` and
give it executable permission (`chmod +x iocmgr.sh`).  I create a `~/bin`
directory for such scripts.

## Download

*Download* `iocmgr.sh` (if not already installed)

```sh
cd ~/bin
wget https://raw.githubusercontent.com/prjemian/epics-docker/main/v2.0/resources/iocmgr.sh
chmod +x iocmgr.sh
```

## Examples

Here are some examples for a GP IOC with prefix `gp`:` and an ADSIM IOC with
prefix `ad1:`:

command | description
--- | ---
`iocmgr.sh start gp gp1` | Start a GP (custom XXX) IOC with prefix `gp1:`
`iocmgr.sh caqtdm gp gp1` | Start caQtDM for the GP IOC with prefix `gp1:`
`iocmgr.sh status gp gp1` | Show status of the GP IOC with prefix `gp1:`
`iocmgr.sh stop gp gp1` | Show status of the GP IOC with prefix `gp1:`
`iocmgr.sh start adsim ad1` | Start a ADSIM (custom ADSimDetector) IOC with prefix `ad1:`
`iocmgr.sh caqtdm adsim ad1` | Start caQtDM for the ADSIM IOC with prefix `ad1:`
`iocmgr.sh status adsim ad1` | Show status of the ADSIM IOC with prefix `ad1:`
`iocmgr.sh stop adsim ad1` | Show status of the ADSIM IOC with prefix `ad1:`
