# README.md

-tba-

### Wahoo!

```
(base) mintadmin@mint-vm:~/.../epics-docker/n4_areaDetector$ docker run -d --net=host --name iocadsky -e "AD_PREFIX=adsky:" prjemian/synapps-6.1-ad-3.7 bash -c "while true; do date; sleep 10; done" 
a01da74176d01d07720defec81d87554432bd9a8742c3853cf91e6a71164e1da
(base) mintadmin@mint-vm:~/.../epics-docker/n4_areaDetector$ docker exec iocadsky iocSimDetector/simDetector.sh start
Starting simDetector
(base) mintadmin@mint-vm:~/.../epics-docker/n4_areaDetector$ caget adsky:cam1:Acquire
adsky:cam1:Acquire             Done
```
