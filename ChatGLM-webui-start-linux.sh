#!/usr/bin/env bash

cd "${PWD}/" || { printf "\e[1m\e[31m[ERROR] \e[0mCan't cd, aborting...\n\e[0m"; exit 1; }

# dialog config
height=15
width=40
choose_height=4

# python3 executable
if [[ -z "${python_cmd}" ]]
then
    python_cmd="python3"
fi
if [[ -z "${pip_cmd}" ]]
then
    pip_cmd="pip"
fi
if [[ -z "${dialog_cmd}" ]]
then
    dialog_cmd="dialog"
fi
if [[ -z "${gcc_cmd}" ]]
then
    gcc_cmd="gcc"
fi

# git executable
if [[ -z "${GIT}" ]]
then
    export GIT="git"
fi

# Name of the subdirectory (defaults to ChatGLM-webui)
if [[ -z "${clone_dir}" ]]
then
    clone_dir="ChatGLM-webui"
fi

if [[ -z "${LAUNCH_SCRIPT}" ]]
then
    LAUNCH_SCRIPT="webui.py"
fi

# this script cannot be run as root by default
ingone_root=0

# Do not reinstall existing pip packages on Debian/Ubuntu
export PIP_IGNORE_INSTALLED=0

function setup()
{
    options=(1 "next"
             2 "exit")
    choice=$(dialog --clear \
                --backtitle "ChatGLM-webui-autoinstall" \
                --title "SETUP" \
                --menu "welcome to ChatGLM webui install script" \
                $height $width $choose_height \
                "${options[@]}" \
                2>&1 >/dev/tty)
    clear
    case $choice in
        1)
         echo 1
         ;;
        2)
         echo canceled by user.
         exit 1
         ;;
        "")
         echo canceled by user.
         exit 1
         ;;
        *) 
          echo invaild choice
          exit 1
    esac

     options=(1 "ghproxy"
              2 "official")
    choice=$(dialog --clear \
                --backtitle "ChatGLM-webui-autoinstall" \
                --title "SETUP" \
                --menu "select git source" \
                $height $width $choose_height \
                "${options[@]}" \
                2>&1 >/dev/tty)
    clear
    case $choice in
        1)
         echo 1
         gitsource=https://ghproxy.com/https://github.com
         ;;
        2)
         echo 2
         gitsource=https://github.com
         ;;
        "")
         echo canceled by user.
         exit 1
         ;;
        *) 
          echo invaild choice
          exit 1
    esac

    options=(1 "NVIDIA(CUDA11.7)"
             2 "CPU")
    choice=$(dialog --clear \
                --backtitle "ChatGLM-webui-autoinstall" \
                --title "SETUP" \
                --menu "select pytorch type" \
                $height $width $choose_height \
                "${options[@]}" \
                2>&1 >/dev/tty)
    clear
    case $choice in
        1)
         echo 1
         torchver=nv
         ;;
        2)
         echo 2
         torchver=cpu
         ;;
        "")
         echo canceled by user.
         exit 1
         ;;
        *) 
          echo invaild choice
          exit 1
    esac

    options=(1 "NORMAL"
             2 "INT4"
             3 "INT4-QE")
    choice=$(dialog --clear \
                --backtitle "ChatGLM-webui-autoinstall" \
                --title "SETUP" \
                --menu "select model type" \
                $height $width $choose_height \
                "${options[@]}" \
                2>&1 >/dev/tty)
    clear
    case $choice in
        1)
         echo 1
         model=chatglm-6b
         ;;
        2)
         echo 2
         model=chatglm-6b-int4
         ;;
        3)
         echo 3
         model=chatglm-6b-int4-qe
         ;;
        "")
         echo canceled by user.
         exit 1
         ;;
        *) 
          echo invaild choice
          exit 1
    esac

    printf "\e[1m\e[34m[INFO] \e[0mInstalling webui...\n"

    if [[ -d ChatGLM-webui ]]
    then
        printf "\n%s\n" "${delimiter}"
        printf "Repo already cloned, using it as install directory"
        printf "\n%s\n" "${delimiter}"
        clone_dir="${PWD}/${clone_dir}"
    else
        printf "\n%s\n" "${delimiter}"
        printf "Clone ChatGLM-webui"
        printf "\n%s\n" "${delimiter}"
        "${GIT}" clone "${gitsource}/Akegarasu/ChatGLM-webui.git" "${clone_dir}" || { "${GIT}" clone https://ghproxy.com/https://github.com/AUTOMATIC1111/ChatGLM-webui.git "${clone_dir}"; }
        clone_dir="${PWD}/${clone_dir}"
    fi
    cd "${clone_dir}"/ || { printf "\e[1m\e[31m[ERROR] \e[0mCan't cd to %s/, aborting...\e[0m" "${clone_dir}"; exit 1; }
    if [ ! -s "${LAUNCH_SCRIPT}" ] 
    then
        printf "\e[1m\e[31m[ERROR] \e[0mCan't find launch script, aborting...\e[0m"
        exit 1
    fi
    printf "\e[1m\e[34m[INFO] \e[0m Install requirements...\n"
    "${python_cmd}" -m "${pip_cmd}" install --upgrade pip setuptools -i https://pypi.tuna.tsinghua.edu.cn/simple
    if [ $torchver = "nv" ]
    then
        "${pip_cmd}" install torch==1.13.1+cu117 torchvision==0.14.1+cu117 xformers --extra-index-url https://download.pytorch.org/whl/cu117 -i https://pypi.tuna.tsinghua.edu.cn/simple || { printf "\e[1m\e[31m[ERROR] \e[0mInstall failed, aborting...\e\n[0m"; exit 1; }
    elif [ $torchver = "cpu" ]
    then
        "${pip_cmd}" install torch==1.13.1+cpu torchvision==0.14.1+cpu basicsr==1.4.2 --extra-index-url https://download.pytorch.org/whl/cpu -i https://pypi.tuna.tsinghua.edu.cn/simple || { printf "\e[1m\e[31m[ERROR] \e[0mInstall failed, aborting...\e\n[0m"; exit 1; }
    fi
    "${pip_cmd}" install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple || { printf "\e[1m\e[31m[ERROR] \e[0mInstall failed, aborting...\e\n[0m"; exit 1; }
    "${GIT}" lfs install || { printf "\e[1m\e[31m[ERROR] \e[0mInstall failed, aborting...\e\n[0m"; exit 1; }
    "${GIT}" clone "https://huggingface.co/THUDM/${model}" || { printf "\e[1m\e[31m[ERROR] \e[0mInstall failed, aborting...\e\n[0m"; exit 1; }

    options=(1 "none"
             2 "int8"
             3 "int4"
             4 "only CPU")
    choice=$(dialog --clear \
                --backtitle "ChatGLM-webui-autoinstall" \
                --title "SETUP" \
                --menu "select command args" \
                $height $width $choose_height \
                "${options[@]}" \
                2>&1 >/dev/tty)
    clear
    case $choice in
        1)
         echo 1
         method=1
         ;;
        2)
         echo 2
         method=2
         ;;
        3)
         echo 3
         method=3
         ;;
        4)
         echo 4
         method=4
         ;;
        "")
         echo canceled by user.
         exit 1
         ;;
        *) 
          echo invaild choice
          exit 1
    esac
    cd ..
    printf "[info]\r\nmethod=%s\nmodel=%s" "${method}" "${model}">>installed.ini
    printf "\e[1m\e[34m[INFO] \e[0mInstalled.\n"
}

function change_source()
{
if [ -s /etc/apt/sources.list.bak ]
then
    sudo cp /etc/apt/sources.list.bak /etc/apt/sources.list
    sudo rm -f /etc/apt/sources.list.bak
    sudo apt update
else
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    sudo sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
    sudo sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
    sudo apt update
fi
}

delimiter="################################################################"

printf "\n%s\n" "${delimiter}"
printf "\e[1m\e[32mInstall script for ChatGLM Web UI\n"
printf "\e[1m\e[34mTested on Ubuntu 22.04\e[0m"
printf "\n%s\n" "${delimiter}"

# if run as root
if [[ "$(id -u)" -eq "0" && ingone_root -eq "0" ]]
then
    printf "\n%s\n" "${delimiter}"
    printf "Running on \e[1m\e[32m%s\e[0m user" "$(whoami)"
    printf "\n\e[1m\e[33mWARN: Launched this script as root may cause bugs.\e[0m"
    printf "\n%s\n\n" "${delimiter}"
else
    printf "\n%s\n" "${delimiter}"
    printf "Running on \e[1m\e[32m%s\e[0m user" "$(whoami)"
    printf "\n%s\n\n" "${delimiter}"
fi

printf "\e[1m\e[33m[WARN] \e[0mNOTE:This script is in early progress,and may including bugs.\n"

printf "\e[1m\e[32m[INFO] \e[0mAccess root perm...\n"
sudo -l >/dev/null
exit_code=$?
if [ ${exit_code} -ne 0 ]
then
    printf "\e[1m\e[31m[ERROR] \e[0mAccess failed.Exiting...\n"
    exit ${exit_code}
else
    printf "\e[1m\e[32m[INFO] \e[0mAccess complete.\n"
fi


if [[ -d .git ]]
then
    printf "\n%s\n" "${delimiter}"
    printf "Running script in install directory"
    printf "\n%s\n" "${delimiter}"
    installed_script=1
else
    printf "\n%s\n" "${delimiter}"
    printf "Running script in unknown directory\n"
    printf "\e[1m\e[33mWARN: It is recommand to run in a repo directory."
    printf "\n%s\n" "${delimiter}"
    installed_script=0
fi

if [ $installed_script = "1" ]
then
printf "\e[1m\e[32m[INFO] \e[0mUpdating...\n"
"${GIT}" pull || printf "\e[1m\e[33m[WARN] \e[0mUpdate failed.\n"
fi

printf "\e[1m\e[32m[INFO] \e[0mCheck program integrity...\n"
for preq in "${GIT}" "${python_cmd}" "${pip_cmd}" "${dialog_cmd}" "${gcc_cmd}"
do
    if ! hash "${preq}" &>/dev/null
    then
        printf "\e[1m\e[33m[WARN] \e[0m%s is not installed, installing...\n" "${preq}"
        printf "       When installed failed,try sudo apt update.\n"
        sudo apt install -y "${preq}" --fix-missing
    fi
done

if [ ! -s installed.ini ] 
then
    printf "\e[1m\e[32m[INFO] \e[0mProgram is not installed,running setup...\n"
    setup
else
    method="$(sed '\/method=/!d;s/.*=//' installed.ini)"
    printf "method: %s\n" "${method}"
    model="$(sed '\/model=/!d;s/.*=//' installed.ini)"
    printf "model: %s" "${model}"
fi

if [ "$method" = "1" ]
then
ARGS=""
elif [ "$method" = "2" ]
then
ARGS="--precision int8"
elif [ "$method" = "3" ]
then
ARGS="--precision int4"
elif [ "$method" = "4" ]
then
ARGS="--precision int4 --cpu"
fi

###############################启动参数###############################
#export PYTHON=
#export GIT=
#export VENV_DIR=
export COMMANDLINE_ARGS=$ARGS
#####################################################################

if [[ -d ChatGLM-webui ]]
then
    printf "\n%s\n" "${delimiter}"
    printf "Repo already cloned, using it as install directory"
    printf "\n%s\n" "${delimiter}"
    clone_dir="${PWD}/${clone_dir}"
fi

if [[ -d "${clone_dir}" ]]
then
    cd "${clone_dir}"/ || { printf "\e[1m\e[31m[ERROR] \e[0mCan't cd to %s/, aborting...\e[0m" "${clone_dir}"; exit 1; }
else
    exit 1
fi

if [ ! -s "${LAUNCH_SCRIPT}" ] 
then
    printf "\e[1m\e[31m[ERROR] \e[0mCan't find launch script, aborting...\e[0m"
    exit 1
fi

printf "\n%s\n" "${delimiter}"
printf "Launching web.py..."
printf "\n%s\n" "${delimiter}"      
exec "${python_cmd}" "${LAUNCH_SCRIPT}" ${COMMANDLINE_ARGS} --model-path "${model}" --listen "$@"
