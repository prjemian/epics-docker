# epics-docker
Build EPICS docker images

### portainer to manage docker locally
using portainer (from [portainer.io](https://portainer.io)), 
see https://www.portainer.io/installation/

    docker run \
        -d \
        -p 8000:8000 \
        -p 9000:9000 \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data portainer/portainer

    firefox http://localhost:9000 &

----

* moved here from https://github.com/prjemian/virtualbeamline
* which was forked from https://github.com/KedoKudo/virtualbeamline
