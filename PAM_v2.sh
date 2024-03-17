#!/bin/bash
# --------------------------------------------------------------------------------------
#          PAM
#
#          Bash script to install: 
#          virtualbox/vagrant/vagrant manager/singularity/anaconda
#
# --------------------------------------------------------------------------------------


## VERSIONS:
# Version 2.0: 
### For Version 3.0: TODO: Set a working dir
### Windows: %APPDATA%
### MacOS: Users/username/tmp/ or something 
### Also move these version requirements to Jira.

# --------------------------------------------------------------------------------------
#                                       Assumptions
# --------------------------------------------------------------------------------------
# You are running this in GitBash or a similar Unix shell which has access to wget, echo, etc..

# --------------------------------------------------------------------------------------
#                                       Dependencies
# --------------------------------------------------------------------------------------
# installing vm-singularity: virtualbox, vagrant, vagrant manager
wget https://download.virtualbox.org/virtualbox/6.1.46/VirtualBox-6.1.46-158378-Win.exe

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant

wget -v https://github.com/lanayotech/vagrant-manager-windows/releases/download/1.0.2.2/VagrantManager-1.0.2.2-Setup.exe
# the -v means verbose, and it will tell you all the steps it is doing

# Check which OS we are on, then pull down the required Setup.

# Cygwin is the Linux emulation environment inside of Git Bash inside of Windows x64
# Darwin is MacOS (UNIX)
# Linux-GNU is Linux (most types)


# Check if Windows is first because we expect Windows.

if [[ "$OSTYPE" == "cygwin" ]]; then
    print "You are on Windows. Downloading and installing Vagrant Manager"
    wget -v https://github.com/lanayotech/vagrant-manager-windows/releases/download/1.0.2.2/VagrantManager-1.0.2.2-Setup.exe /a
    ./VagrantManager-1.0.2.2-Setup.exe /? # Check for the potential flags to silent install
    ./VagrantManager-1.0.2.2-Setup.exe    # Run the silent install, it's possible this could fail due to you not being an administrator
    # TODO: Lookup silent install flag for VagrantManager, if it exists.
    # TODO: Lookup an MSI for Vagrant Manager, couldn't find one from the GitHub Repo and it looked like there were some shady looking MSIs online.
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    print "You are on Linux, so you can't use Vagrant Manager. Sorry."
elif [[ "$OSTYPE" == "linux-64"* ]]; then
    print "You are on Linux x64, so you can't use Vagrant Manager. Sorry."
elif [[ "$OSTYPE" == "darwin22.0"* ]]; then
    print "You are on MacOS (Unix). Downloading and installing Vagrant Manager."
    wget -v https://github.com/lanayotech/vagrant-manager/releases/download/2.7.1/vagrant-manager-2.7.1.dmg
    ./vagrant-manager-2.7.1.dmg
elif [[ "$OSTYPE" == "darwin"* ]]; then
    print "You are on MacOS (Older Intel Mac). Downloading and installing Vagrant Manager."
    wget -v https://github.com/lanayotech/vagrant-manager/releases/download/2.7.1/vagrant-manager-2.7.1.dmg
    ./vagrant-manager-2.7.1.dmg
else
    print "Something unexpected was reported. Here is the detected OS:"
    print $OSTYPE 

fi

# --------------------------------------------------------------------------------------
#                                 Installing Singularity
# --------------------------------------------------------------------------------------
mkdir vm-singularity
export VM=sylabs/singularity-3.0-ubuntu-bionic64 && \
    vagrant init $VM && \
    vagrant up && \
    vagrant ssh

# --------------------------------------------------------------------------------------
#                                  Installing Anaconda
# --------------------------------------------------------------------------------------
mkdir tmp
cd tmp 

# Download the shell script from the Internet
wget https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh

bash Anaconda3-2020.05-Linux-x86_64.sh 


# Add the new Anaconda installation to PATH
# Check PATH with this:
echo $PATH

export PATH=$HOME/anaconda/bin:$PATH 
# Telling your machine where anconda alreadly is.


# Try to create a conda environment and then, if that fails
# Take conda env list (which shows all conda environments, and dump it (>) to a text file)

{ # Try to create a conda environment with the name of softdev

    conda create --name softdev python=3.10 
    conda activate softdev
    &&

} || { # If this fails, save out a log 

    conda --version > conda_version.txt
    conda env list > conda_log.txt

}

fi
