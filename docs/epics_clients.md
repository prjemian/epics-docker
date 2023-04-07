# EPICS Client Software

The EPICS client software packages in the next table each provide control and/or
image viewer capabilities.

package | command line controls | GUI controls | image viewer
--- | --- | --- | ---
bluesky | yes | notebook | notebook
c2DataViewer | no | no | yes (PVA)
caQtDM | no | yes | yes (CA)
CSS BOY | no | yes | yes
imageJ | no | no | yes
MEDM | no | yes | no
p4p | yes | no | no
phoebus | no | yes | yes
pvapy | yes (PVA) | ? | no
PyDM |  | yes | yes (CA)
pyepics | yes | notebook | no
SPEC | yes | no | no

- CA: Epics Channel Access protocol
- PVA: EPICS PV Access protocol
- notebook: Jupyter notook

**Note**: These EPICS client packages are not part of the `prjemian/synapps` docker
image.
