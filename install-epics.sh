#!/bin/bash

# install EPICS base, synApps, and areaDetector on Linux
#
# usage ./install-epics.sh [EPICS_ROOT_DIRECTORY]

export EPICS_ROOT=${1:-/usr/local/epics}
# export EPICS_ROOT=/opt/epics

export BASE_VERSION=base-7.0.3.1
export SYNAPPS_VERSION=synApps-6.1

#----------------------------------------------------

if [ "Linux" != "`uname -s`" ]; then
    echo "This script should be run in Linux OS"
    exit 1
fi

export _distro=`grep ID_LIKE /etc/os-release | sed s:'ID_LIKE=':'':g | sed s:'\"':'':g`
echo "Identified Linux distribution type: ${_distro}"

#- prep ---------------------------------------------------
if [ -d "${EPICS_ROOT}" ]; then
    echo "EPICS installation directory: ${EPICS_ROOT}"
else
    echo "First, must create installation directory: ${EPICS_ROOT}"
    echo "This command is suggested:"
    echo "sudo mkdir -p ${EPICS_ROOT} && sudo chown ${USER}:${USER} ${EPICS_ROOT}"
    exit 1
fi

#- prep ---------------------------------------------------

case "`uname -m`" in
    x86_64)
        export _n_processors=`grep processor /proc/cpuinfo | wc -l`
        export MAKE_OPTIONS=" -j${_n_processors}"
        ;;
    arm)
        # RaspberryPi limit to no more than 2
        export MAKE_OPTIONS=
        ;;
    *)
        export MAKE_OPTIONS=
        ;;
esac

#- prep ----------------------------------------------------

function check_ubuntu_packages {
    # On Ubuntu, these packages (at least) must be installed:
    _packages+=" git"
    _packages+=" g++"
    _packages+=" re2c"
    _packages+=" libnet1-dev"
    _packages+=" libpcap-dev"
    _packages+=" libusb-1.0-0-dev"
    _packages+=" libx11-dev"
    _packages+=" libxext-dev"
    # screen is used to run synApps IOCs in detached sessions
    _packages+=" screen"
    export _result=`dpkg -V ${_packages} 2>&1`
    # echo "${_result}"
    if [ "" == "${_result}" ]; then
        echo "Required Ubuntu packages are installed: ${_packages}"
    else
        echo "${_result}"
        echo "These packages must be installed first.  This command is suggested:"
        echo "sudo apt-get install -y ${_packages}"
        exit 1
    fi
}

function check_fedora_packages {
    # On RHEL7, these packages (at least) must be installed:
    #_packages+=" git"
    #?_packages+=" g++"
    #_packages+=" re2c"
    _packages+=" libnet-devel"
    #?_packages+=" libpcap-devel"
    #?_packages+=" libusb-1.0-0-devel"
    #?_packages+=" libx11-devel"
    #?_packages+=" libxext-devel"
    # screen is used to run synApps IOCs in detached sessions
    _packages+=" screen"
    export _result=`rpm -q ${_packages} 2>&1`
    # echo "${_result}"
    if [ "" == "${_result}" ]; then
        echo "Required RHEL/fedora packages are installed: ${_packages}"
    else
        echo "${_result}"
        echo "These packages must be installed first.  This command is suggested:"
        echo "sudo yum install -y ${_packages}"
        exit 1
    fi
}

function unknown_distro {
    echo "This installer is not (yet) configured for ${_distro} Linux" 
    cat /etc/os-release
    exit 1
}

case "${_distro}" in
    ubuntu) check_ubuntu_packages ;;
    "fedora" ) check_fedora_packages ;;
    *) unknown_distro ;;
esac

#----------------------------------------------------

function logmake
{
    echo '#-----------------------------------------' 2>&1 tee -a makelog.txt
    date 2>&1 | tee -a makelog.txt
    echo '#begin CMD: make' $@ 2>&1 | tee -a makelog.txt
    make ${MAKE_OPTIONS} $@ | tee -a makelog.txt
    echo '#done CMD: make' $@ 2>&1 | tee -a makelog.txt
    date 2>&1 | tee -a makelog.txt
}

#- EPICS base ---------------------------------------------------

cd ${EPICS_ROOT}
wget http://www.aps.anl.gov/epics/download/base/${BASE_VERSION}.tar.gz
tar xzf ${BASE_VERSION}.tar.gz
/bin/rm ${BASE_VERSION}.tar.gz
# for convenience, make a soft link
ln -s ./${BASE_VERSION} ./base

export EPICS_BASE=${EPICS_ROOT}/base
export EPICS_HOST_ARCH=`${EPICS_BASE}/startup/EpicsHostArch`

# compile EPICS base
cd ${EPICS_BASE}
logmake ${MAKE_OPTIONS}

export PATH=${PATH}:${EPICS_BASE}/bin/${EPICS_HOST_ARCH}
# and for good measure (might not be needed)
export PATH=${PATH}:${EPICS_BASE}/lib/${EPICS_HOST_ARCH}

#- synApps ---------------------------------------------------

cd ${EPICS_ROOT}
export SYNAPPS_DIR=${SYNAPPS_VERSION}__${BASE_VERSION}
wget https://raw.githubusercontent.com/EPICS-synApps/support/master/assemble_synApps.sh

# edit assemble_synApps.sh
sed -i s:'/APSshare/epics/base-3.15.6':'${EPICS_BASE}':g assemble_synApps.sh
# do NOT build these for linux
sed -i s:'ALLENBRADLEY=':'#!ALLENBRADLEY=':g         assemble_synApps.sh
sed -i s:'CAMAC=':'#!CAMAC=':g                       assemble_synApps.sh
sed -i s:'DAC128V=':'#!DAC128V=':g                   assemble_synApps.sh
sed -i s:'DELAYGEN=':'#!DELAYGEN=':g                 assemble_synApps.sh
sed -i s:'DXP=':'#!DXP=':g                           assemble_synApps.sh
sed -i s:'DXPSITORO=':'#!DXPSITORO=':g               assemble_synApps.sh
sed -i s:'IP330=':'#!IP330=':g                       assemble_synApps.sh
sed -i s:'IPUNIDIG=':'#!IPUNIDIG=':g                 assemble_synApps.sh
sed -i s:'LOVE=':'#!LOVE=':g                         assemble_synApps.sh
sed -i s:'QUADEM=':'#!QUADEM=':g                     assemble_synApps.sh
sed -i s:'SOFTGLUE=':'#!SOFTGLUE=':g                 assemble_synApps.sh
sed -i s:'SOFTGLUEZYNQ=':'#!SOFTGLUEZYNQ=':g         assemble_synApps.sh
sed -i s:'VAC=':'#!VAC=':g                           assemble_synApps.sh
sed -i s:'VME=':'#!VME=':g                           assemble_synApps.sh
sed -i s:'YOKOGAWA_DAS=':'#!YOKOGAWA_DAS=':g         assemble_synApps.sh

bash ./assemble_synApps.sh
mv ./assemble_synApps.sh ${SYNAPPS_DIR}

cd ${SYNAPPS_DIR}/support
# undo some changes from the assemble_synApps.sh script since this is now EPICS 7
sed -i s:'WITH_PVA = NO':'WITH_PVA = YES':g    areaDetector-master/configure/CONFIG_SITE.local
sed -i s:'WITH_QSRV = NO':'WITH_QSRV = YES':g  areaDetector-master/configure/CONFIG_SITE.local
# TODO: other changes?

# compile synApps
logmake ${MAKE_OPTIONS}

#- recommendations ---------------------------------------------------

echo "It is recommended to add these lines to your ~/.bash_aliases file:"
cat <<EOF

# file:  ~/.bash_aliases

function logmake
{
    echo '#-----------------------------------------' >> makelog.txt
    date >> makelog.txt
    echo '#begin CMD: make' $@ >> makelog.txt
    make ${MAKE_OPTIONS} $@ 2>&1 >> makelog.txt
    echo '#done CMD: make' $@ >> makelog.txt
    date >> makelog.txt
}

export EPICS_ROOT=${EPICS_ROOT}
export EPICS_BASE=\${EPICS_ROOT}/base
export EPICS_HOST_ARCH=\`\${EPICS_BASE}/startup/EpicsHostArch\`
export PATH=\${PATH}:\${EPICS_BASE}/bin/\${EPICS_HOST_ARCH}
export PATH=\${PATH}:\${EPICS_BASE}/lib/\${EPICS_HOST_ARCH}

EOF

echo "(`date`) These EPICS packages are built:"
echo "EPICS base: ${EPICS_ROOT}/${BASE_VERSION}"
echo "EPICS synApps, : ${EPICS_ROOT}/${SYNAPPS_DIR}"
echo "EPICS areaDetector: ${EPICS_ROOT}/${SYNAPPS_DIR}/support/areaDetector-master"
