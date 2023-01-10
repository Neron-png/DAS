#!/bin/bash
#This is a shell script that will enable developers to download easily their preferred tools with a few keypresses
#Copyright (C) 2022 Apostolos Halis 
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <https://www.gnu.org/licenses/>.

#glbal variables 
correct=false #this is used in input checks 
#names for open/closed source packages for Debian and Arch derivatives 
#declaring arrays 
#python 
declare -a open_source_debian_python 
declare -a proprietary_debian_python
declare -a open_source_arch_python
declare -a proprietary_arch_python 
#C/C++ 
declare -a open_source_debian_CCPP
declare -a proprietary_debian_CCPP
declare -a open_source_arch_CCPP
declare -a proprietary_arch_CCPP
#java 
declare -a open_source_debian_java
declare -a proprietary_debian_java
declare -a open_source_arch_java
declare -a proprietary_arch_java
#distributor ID array 
declare -a distributor_id # this were all the distributor IDs are 
#initilizing arrays 
#the one rule in building extra arrays is to place the packages that need a different package manager first (the reason behind this will be explained
#in the installing part of this scirpt)
#FORMAT: array_i_declared=("package installed with yay AUR helper" "package installed by pacman" "package installed by pacman")
#python 
open_source_debian_python=("pycharm-community --classic" "python3" "python3-pip")
proprietary_debian_python=("pycharm-professional --classic" "python3" "python3-pip")
open_source_arch_python=("pycharm-community-edition" "python3" "python-pip")
proprietary_arch_python=("pycharm-professional" "python3" "python-pip") #this requires yay or another AUR helper
#C/C++ 
open_source_debian_CCPP=("codeblocks" "build-essential") #needs universe repo activation 
proprietary_debian_CCPP=("clion --classic" "build-essential") #this requires snap 
open_source_arch_CCPP=("codeblocks" "base-devel")
proprietary_arch_CCPP=("clion" "base-devel") #this requires yay or another AUR helper
#java 
open_source_debian_java=("intellij-idea-community --classic" "default-jdk")
proprietary_debian_java=("intellij-idea-professional --classic" "software-properties-common" "oracle-java11-installer") #this requires enabling a PPA
open_source_arch_java=("intellij-idea-community-edition" "jdk-openjdk")
proprietary_arch_java=("intellij-idea-ultimate-edition" "jre-lts") #this requires yay or another AUR helper
#distributor ID 
distributor_id=("arch" "manjaro" "debian" "ubuntu" "mint" "pop")

#Greeting the user
echo "--------------------------------------------------"
echo "-- Welcome to Toli's Developer assistant script --"
echo "--------------------------------------------------"

    ###############################################
######checking if required commands are installed######
    ###############################################
#This script requires some commands to work and this part of the code is checking if they are installed. 
#List of the required commands: 
#2) snap
#3) yay 

#This file has the ID of the linux distribution that is being used by the user. 
#It is being sourced here so I can access the $ID
. /etc/os-release

#I am only checking if snap is installed in Debian derivatives because none of the Arch one need it 
if [ "$ID" = "${distribution_id[2]}" ] || [ "$ID" = "${distribution_id[3]}" ] || [ "$ID" = "${distribution_id[4]}" ] || [ "$ID" = "${distribution_id[5]}" ]; then 
    #checking if the snap package manager is available (it will be needed for some of the software installed)
    if ! command -v snap > /dev/null; then 
        echo "snap command was not found. Please install snapcraft from snapcraft.io and try running the script again."
        exit 1
    fi
fi 

#I am only checking if yay is installed on Arch derivatives because yay is an AUR helper and AUR is only available for Arch derivatives 
if [ "$ID" = "${distributor_id[0]}" ] || [ "$ID" = "${distributor_id[1]}" ]; then 
    #checking if the yay AUR helper is available (it will be needed for some of the software installed)
    if ! command -v yay > /dev/null; then 
        echo "yay command was not found. Please install the yay AUR helper aur.archlinux.org/packages/yay from and try running the script again."
        exit 1
    fi
fi 

    ############################
######getting user preferences#####
    ############################
#I need to know if the user prefers open source or propiatery software and the user's preferred language
#getting the user's preference on source code access 
read -p"Do you prefer open source software (a) or proprietary software (b): " software_type
if [ "$software_type" != "a" ] && [ "$software_type" != "b" ]; then 
        correct=false
else 
    correct=true
fi
while [ "$correct" = false ]
do 
    read -p"Do you prefer open source software (a) or proprietary software (b): " software_type 
    if [ "$software_type" != "a" ] && [ "$software_type" != "b" ]; then 
        correct=false
    else 
        correct=true
fi
done

#Getting the user's preferred language
read -p"Choose the language that you want to install tools for"$'\n'"a)Python"$'\n'"b)C/C++"$'\n'"c)Java"$'\n' language
if [ "$language" != "a" ] && [ "$language" != "b" ] && [ "$language" != "c" ]; then 
        correct=false
else 
    correct=true
fi
while [ "$correct" = false ]
do 
    read -p"Choose the language that you want to install tools for"$'\n'"a)Python"$'\n'"b)C/C++"$'\n'"c)Java"$'\n' language
    if [ "$language" != "a" ] && [ "$language" != "b" ] && [ "$language" != "c" ]; then 
        correct=false
    else 
        correct=true
fi
done
   ###################
#####installing part#####
   ###################
#this part starts with the script getting once again the os that the user is using 
#there is a switch statement with one case for every language 
#in every case I placed two loops the one will loop through and install every item of the open source version 
#of the list and the other will loop through the propietary version of the list
#You will notice that in some loops we start from the second item
#that is happening because some items need to be installed with another package manager, that's why I first install them 
#then I set a counter that excludes them from the loop and finally I go through the loop
#Those items as adviced by the array building 
#rules above should be placed first in the loop so this can happen easily
if [ "$ID" = "${distribution_id[2]}" ] || [ "$ID" = "${distribution_id[3]}" ] || [ "$ID" = "${distribution_id[4]}" ] || [ "$ID" = "${distribution_id[5]}" ]; then 
    case $language in 
        a) 
            echo "Python toolchain will be downloaded..."
            if [ "$software_type" = "a" ]; then 
                for item in ${open_source_debian_python[@]}; do 
                    apt install $item 
                done 
            else 
                for item in ${proprietary_debian_python[@]}; do 
                    apt install $item 
                done
            fi 
            ;; 
        b) 
            echo "C/C++ toolchain will be downloaded..."
            if [ "$software_type" = "a" ]; then 
            #just a repository adding to install codeblocks (not loop method needed)
                add-apt-repository universe
                for item in ${open_source_debian_CCPP[@]}; do 
                    apt install $item 
                done 
            else 
                snap install ${proprietary_debian_CCPP[0]}
                i=1
                while [ "$i" -lt "${#proprietary_debian_CCPP[@]}" ]; do 
                    apt install "${proprietary_debian_CCPP[i]}"
                    i=$((i+1))
                done
            fi

            ;; 
        c) 
            echo "Java will be downloaded..."
            if [ "$software_type" = "a" ]; then 
                for item in ${open_source_debian_java[@]}; do 
                    apt install $item 
                done 
            else 
                add-apt-repository ppa:linuxuprising/java
                for item in ${proprietary_debian_java[@]}; do 
                    apt install $item 
                done
            fi 
            ;; 
    esac
elif [ "$ID" = "${distributor_id[0]}" ] || [ "$ID" = "${distributor_id[1]}" ]; then 
    case $language in 
        a) 
            echo "Python toolchain wll be downloaded..."
            if [ "$software_type" = "a" ]; then 
                for item in ${open_source_arch_python[@]}; do 
                    pacman -S $item 
                done 
            else 
                yay -S ${proprietary_arch_python[0]}
                i=1
                while [ "$i" -lt "${#proprietary_arch_python[@]}" ]; do 
                    pacman -S "${proprietary_arch_python[i]}"
                    i=$((i+1))
                done
            fi
            ;; 
        b) 
            echo "C/C++ toolchain will be downloaded..."
            if [ "$software_type" = "a" ]; then 
                for item in ${open_source_arch_CCPP[@]}; do 
                    pacman -S $item 
                done 
            else 
                yay -S ${proprietary_arch_python[0]}
                i=1
                while [ "$i" -lt "${#proprietary_arch_CCPP[@]}" ]; do 
                    pacman -S "${proprietary_arch_CCPP[i]}"
                    i=$((i+1))
                done
            fi
            ;; 
        c) 
            echo "Java toolchain will be downloaded..."
            if [ "$software_type" = "a" ]; then 
                for item in ${open_source_arch_java[@]}; do 
                    pacman -S $item 
                done 
            elif [ "$software_type" = "b" ]; then 
                for item in ${open_source_arch_java[@]}; do 
                    yay -S $item 
                done 
            fi 
            ;; 
    esac
fi