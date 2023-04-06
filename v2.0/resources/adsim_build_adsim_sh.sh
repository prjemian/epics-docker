#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ starter shortcut"

cat >> "${HOME}/bin/adsim.sh"  << EOF
#!/bin/bash

source "${HOME}/.bash_aliases"

export PREFIX=\${PREFIX:-adsim:}
# echo "PREFIX=\${PREFIX}"

PRE="\${PREFIX:0:-1}"  # remove the trailing colon
# echo "PRE=\${PRE}"

cd "${IOCADSIM}/softioc"
bash ./adsim.sh "\${1}"

publish_synApps_screens(){
    pushd "${SUPPORT}"
    tar cf - screens | (cd /tmp && tar xf -)
    popd
}

publish_ioc_custom_screens(){
    pushd "${IOCADSIM}"
    tar cf - screens | (cd /tmp && tar xf -)
    popd
}

if [ "\${1}" == "start" ]; then
    publish_synApps_screens
    publish_ioc_custom_screens
    # echo "PREFIX=\${PREFIX}  PRE=\${PRE}"

    sed -i s/'SET_EXT'/"ui"/g   "\${RESOURCES}/start_caQtDM.sh"
    sed -i s/'SET_MACRO'/"P=\${PREFIX},R=cam1:"/g   "\${RESOURCES}/start_caQtDM.sh"
    sed -i s/'SET_PREFIX'/"\${PREFIX}"/g   "\${RESOURCES}/start_caQtDM.sh"
    sed -i s/'SET_SCREEN'/"sim_cam_image.ui"/g   "\${RESOURCES}/start_caQtDM.sh"
    cp  "\${RESOURCES}/start_caQtDM.sh"   "/tmp/start_caQtDM_\${PRE}"

    sed -i s/'SET_EXT'/"adl"/g   "\${RESOURCES}/start_MEDM.sh"
    sed -i s/'SET_MACRO'/"P=\${PREFIX},R=cam1:"/g   "\${RESOURCES}/start_MEDM.sh"
    sed -i s/'SET_PREFIX'/"\${PREFIX}"/g   "\${RESOURCES}/start_MEDM.sh"
    sed -i s/'SET_SCREEN'/"simDetector.adl"/g   "\${RESOURCES}/start_MEDM.sh"
    cp  "\${RESOURCES}/start_MEDM.sh"   "/tmp/start_MEDM_\${PRE}"

    # allow more time for the IOC to start (in screen, possibly)
    sleep 2
    bash ./adsim.sh status
fi
EOF
chmod +x "${HOME}/bin/adsim.sh"
