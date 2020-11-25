#!/bin/bash
set -o errexit; set -o pipefail; set -o nounset;

echo "cloudinit ran" >> /tmp/cloudinit

mkdir -m 770 /gitian
chgrp ubuntu /gitian

echo check ebs gitian disk device
fdisk -l | grep Disk | tail -1 > /gitian/disk_info.txt
echo grab disk specific
cat /gitian/disk_info.txt | cut -d'/' -f3 | cut -d':' -f1 > /gitian/specific_disk.txt
export DISK=/dev/`cat /gitian/specific_disk.txt`
file -s $DISK > /gitian/starting_fs_ebs.txt

# format ebs if it isn't already xfs
if grep -q ": data$" "/gitian/starting_fs_ebs.txt"; then
  echo found data device creating xfs fs on $DISK
  mkfs -t xfs $DISK
fi

echo UUID=$(blkid -o value -s UUID $DISK)     /gitian   xfs    defaults,nofail   0   2 | tee -a /etc/fstab
mount -a

apt-get update
echo installing apt-cacher-ng
echo package apt-cacher-ng/tunnelenable {boolean,string} {false, some string}  | debconf-set-selections
apt-get install apt-cacher-ng -y
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common tmux -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint ${DOCKER_FINGERPRINT}
add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y
usermod -aG docker ubuntu
systemctl start docker

docker ps
if [ $? -eq 0 ]; then
    echo Docker installed
else
    echo "Something failed with docker setup, time for a PR or git issue :)"
    exit 1
fi

export USE_DOCKER=1
cd /gitian
git clone https://github.com/bitcoin/bitcoin.git
echo run gitigan setup
bitcoin/contrib/gitian-build.py --setup
echo create base docker image
gitian-builder/bin/make-base-vm --docker --arch amd64 --suite bionic
echo run docker build
echo CORES to use: ${CORES}, memory to use: ${MEMORY}000
bitcoin/contrib/gitian-build.py -j ${CORES} -m ${MEMORY}000 -Ddnb ${VERIFIER_NAME} ${VERSION}

# if you want to be a gitian signer you will need to scp / gpg sign / ssh / create PR  manually
