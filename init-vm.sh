#!/bin/bash
# Author: Andy
# Date: 2022.04.12
# FOR UBUNTU DESKTOP VM FIRST SETUP

HELP=0

DOCKER=0

NORMAL=0

DOWNLAOD_URL="https://mirrors.ustc.edu.cn/repogen/conf/ubuntu-https-4-"

DOCKER_URL="https://get.docker.com"

PIP_SOURCE="https://pypi.tuna.tsinghua.edu.cn/simple"

RED="31m"
GREEN="32m"
YELLOW="33m"
BLUE="36m"
FUCHSIA="35m"

colorEcho(){
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}

while [[ $# > 0 ]];do
    KEY="$1"
    case $KEY in
        -d|--docker)
        DOCKER=1
        ;;
        -h|--help)
        HELP=1
        ;;
        *)
                
        ;;
    esac
    shift 
done

help(){
    echo "bash $0 [-h|--help] [-d|--docker] [-n|--normal]"
    echo "  -h, --help           Show help"
    echo "  -d, --docker         Install docker and other dependent"
    return 0
}

commandExists() {
	command -v "$@" > /dev/null 2>&1
}

checkSys() {

    [ $(id -u) != "0" ] && { colorEcho ${RED} "Error: You must be root to run this script(with sudo)"; exit 1; }

    ARCH=$(uname -m 2> /dev/null)
    if [[ $ARCH != x86_64 && $ARCH != aarch64 ]]; then
        colorEcho $YELLOW "not support $ARCH machine".
        exit 1
    fi

    if [[ `command -v apt-get` ]]; then
        PACKAGE_MANAGER='apt-get'
    else
        colorEcho $RED "Not support OS!"
        exit 1
    fi

    #[[ -z `echo $PATH|grep /usr/local/bin` ]] && { echo 'export PATH=$PATH:/usr/local/bin' >> /etc/bashrc; source /etc/bashrc; }

}

installDependent(){

    colorEcho $GREEN "Update your soures.list set mirrors:mirrors.ustc.edu.cn"
    mv /etc/apt/sources.list /etc/apt/sources.list.bak
    code_name=$(set `lsb_release -c`;echo $2)
    wget ""$DOWNLAOD_URL""$code_name"" -O /etc/apt/sources.list
    colorEcho $GREEN "Install dependent ssh git pip vim vm-tools"
    ${PACKAGE_MANAGER} update && upgrade -y && dist-upgrade -y
    ${PACKAGE_MANAGER} install openssh-server open-vm-tools open-vm-tools-desktop -y
    ${PACKAGE_MANAGER} install build-essential software-properties-common git python3-pip vim -y
    systemctl enable run-vmblock\\x2dfuse.mount
    colorEcho $GREEN "Update your pip config set mirrors:pypi.tuna.tsinghua.edu.cn/simple"
    pip config set global.index-url $PIP_SOURCE
    myUser=`who am i | awk '{print $1}'`
    su $myUser -c "pip config set global.index-url "$PIP_SOURCE""
}

installDocker(){
    if commandExists docker && [ -e /var/run/docker.sock ]; then
        colorEcho $RED "Docker already exist "
        exit 1
    fi
    wget -O - $DOCKER_URL | bash
    myUser=`who am i | awk '{print $1}'`
    groupadd docker | usermod -aG docker $myUser
    colorEcho $GREEN "Add user "myUser" to docker group"
}

normalInstall(){
    checkSys
    installDependent
}

withDocker(){
    normalInstall
    installDocker
}

main(){

    [[ ${HELP} == 1 ]] && help && return
    [[ ${DOCKER} == 1 ]] && withDocker && colorEcho $RED 'need to reboot (init 6)'
    normalInstall
    colorEcho $RED 'need to reboot (init 6)'
}

main
