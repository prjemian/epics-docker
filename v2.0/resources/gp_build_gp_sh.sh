#!/bin/bash

# build ~/bin/gp.sh which manages the IOC in the image

source "${HOME}/.bash_aliases"
export DESTINATION="${HOME}/bin/gp.sh"


cat > "${DESTINATION}"  << EOF
#!/bin/bash

source "${HOME}/.bash_aliases"

export PREFIX=\${PREFIX:-gp:}
# echo "PREFIX=\${PREFIX}"

PRE="\${PREFIX:0:-1}"  # remove the trailing colon
# echo "PRE=\${PRE}"

cd "${IOCGP}/softioc"
bash ./gp.sh "\${1}"

publish_synApps_screens(){
    pushd "${SUPPORT}"
    tar cf - screens | (cd /tmp && tar xf -)
    popd
}

publish_ioc_custom_screens(){
    pushd "${IOCGP}"
    tar cf - screens | (cd /tmp && tar xf -)
    popd
}

if [ "\${1}" == "start" ]; then
    publish_synApps_screens
    publish_ioc_custom_screens
    # echo "PREFIX=\${PREFIX}  PRE=\${PRE}"

    sed -i s/'SET_EXT'/"ui"/g   "\${RESOURCES}/start_caQtDM.sh"
    sed -i s/'SET_MACRO'/"P=\${PREFIX}"/g   "\${RESOURCES}/start_caQtDM.sh"
    sed -i s/'SET_PREFIX'/"\${PREFIX}"/g   "\${RESOURCES}/start_caQtDM.sh"
    sed -i s/'SET_SCREEN'/"xxx.ui"/g   "\${RESOURCES}/start_caQtDM.sh"
    cp  "\${RESOURCES}/start_caQtDM.sh"   "/tmp/start_caQtDM_\${PRE}"

    sed -i s/'SET_EXT'/"adl"/g   "\${RESOURCES}/start_MEDM.sh"
    sed -i s/'SET_MACRO'/"P=\${PREFIX}"/g   "\${RESOURCES}/start_MEDM.sh"
    sed -i s/'SET_PREFIX'/"\${PREFIX}"/g   "\${RESOURCES}/start_MEDM.sh"
    sed -i s/'SET_SCREEN'/"xxx.adl"/g   "\${RESOURCES}/start_MEDM.sh"
    cp  "\${RESOURCES}/start_MEDM.sh"   "/tmp/start_MEDM_\${PRE}"

    # replace `XXX` in xxx screen files with PREFIX
    # Only used in xxx.ui
    sed -i s/XXX/"\${PREFIX}"/g /tmp/screens/ui/xxx.ui

    # rename the xxx screen files to iocPRE (PREFIX without trailing :)
    for f in \$(ls /tmp/screens/*/xxx.*); do
        if [ -e "\${f}" ]; then
            subdir="\${f%/*}"
            filename=$(basename "\${f}")
            ext="\${f##*.}"
            final="\${subdir}/ioc\${PRE}.\${ext}"
            mv "\${f}" "\${final}"
        fi
    done

    # allow more time for the IOC to start (in screen, possibly)
    sleep 2
    bash ./gp.sh status
fi
EOF
chmod +x "${DESTINATION}"
