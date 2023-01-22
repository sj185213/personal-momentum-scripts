#!/bin/bash
ANSIBLE_REPO="silver-infrastructure-momentum-ansible"
MOMENTUM_DIR="$HOME/momentum"
STARTING_WORKING_DIRECTORY="$(pwd)"
HOSTS_FILE="/etc/hosts"

# Colors
BWHITE='\033[1;37m'
YELLOW="\033[0;33m"
BYELLOW="\033[1;33m"
RESET="\033[0m"

echo ""
echo "Checking hosts file for previously configured momentum domains..."
HOSTS_WARNING=false
while read -r line; do 
    if [[ $line =~ "momentum" ]]
    then
        HOSTS_WARNING=true
    fi
done < $HOSTS_FILE
if [ $HOSTS_WARNING = true ]
then
    echo "${BYELLOW}Warning: found a previously configured domain.${RESET}"
    echo "---"
    cat $HOSTS_FILE
    echo "---"
    echo ""
    echo -n "${BWHITE}Do you want to still want to continue anyways? (y/n): ${RESET}"
    read HOSTS_CONTINUE
    if [ -z "$HOSTS_CONTINUE" ]
    then
        echo "momentum reset canceled."
        return
    fi
    if [ $HOSTS_CONTINUE != "y" ]
    then
        echo "momentum reset canceled."
        return
    fi
fi

echo ""
echo "Checking if any virtual machines are lingering..."
VMS="$(vboxmanage list vms)"
if [ ! -z $VMS ]
then
    echo "${BYELLOW}Warning: There are still some virtual machines lingering. You may want to destroy these virtual machines.${RESET}"
    echo "Currently configured virtual machines:"
    echo "$VMS"
    echo ""
    echo -n "${BWHITE}Do you want to continue anyways without destroying these virtual machines (y/n): ${RESET}"
    read VMS_CONTINUE
    if [ -z "$VMS_CONTINUE" ]
    then
        echo "momentum reset canceled."
        return
    fi
    if [ $VMS_CONTINUE != "y" ]
    then
        echo "momentum reset canceled."
        return
    fi
fi

echo "Before resetting momentum, the virtual machine must be destroyed and hosts file should"
echo "not have any previously mapped IP's."
echo ""
echo "${BWHITE}Make sure to be connected to the VPN before going forward${RESET}"
echo ""
echo "${BWHITE}Make sure sudo is working.${RESET} If there are issues, connect to the VPN and run the following commands"
echo "  $ sudo jamf policy -event unbind"
echo "  $ sudo jamf policy -event repairBinding"
echo ""
echo -n "${BWHITE}Continue? (y/n): ${RESET}"
read CONFIRM

if [ -z "$CONFIRM" ]
    then
        echo "momentum reset canceled."
        return
    fi
if [ $CONFIRM != "y" ]
    then
        echo "momentum reset canceled."
        return
    fi

echo "$Going back to home directory and running setup for momentum..."
cd $HOME
mkdir $MOMENTUM_DIR

echo ""
echo "Deleting existing ${ANSIBLE_REPO} repo..."
rm -rf "${MOMENTUM_DIR}/${ANSIBLE_REPO}"
echo "Delete successful!"

echo ""
echo "Cloning repo..."
cd "${MOMENTUM_DIR}"
git clone git@github.com:ncr-swt-hospitality/silver-infrastructure-momentum-ansible.git
echo "Cloning successful!"

cd "${STARTING_WORKING_DIRECTORY}"

echo ""
echo "Adjusting provisioning.yml"
rm "${MOMENTUM_DIR}/${ANSIBLE_REPO}/provisioning.yml"
cp /Users/sj185213/momentum/scripts/provisioning.yml "${MOMENTUM_DIR}/${ANSIBLE_REPO}/provisioning.yml"
echo "provisioning.yml adjusted!"

echo ""
echo "To start up momentum locally after everything has been set"
echo "  cd ${MOMENTUM_DIR}/${ANSIBLE_REPO}"
echo "  direnv allow"
echo "  vagrant up --provision"
