#!/usr/bin/env bash

# set default version and build if not passed via arguments
version=${1:-15.5.0}
build=${2:-1}

# start building from a scratch container
astcontainer=$(buildah from scratch)
astmount=$(buildah mount $astcontainer)

# NOTE: unfortunately release 29 fails to run during a scriptlet on the info package 
dnf install --disablerepo=* --enablerepo=fedora --enablerepo=updates \
    --assumeyes --installroot $astmount --releasever=27 \
    bash coreutils \
    --setopt install_weak_deps=false \
    --setopt tsflags=nodocs

dnf clean all --assumeyes --installroot $astmount --releasever=27

# install Asterisk, pjsip, and HEP
dnf install --disablerepo=* --enablerepo=fedora --enablerepo=updates \
    --assumeyes --installroot $astmount --releasever=29 \
    asterisk-$version asterisk-pjsip-$version asterisk-hep-$version \
    --setopt install_weak_deps=false \
    --setopt tsflags=nodocs

dnf clean all --assumeyes --installroot $astmount --releasever=29

# set metadata for the container
buildah config --annotation "site.nfvpe.asterisk.leifmadsen=$(uname -n)" $astcontainer
buildah config --cmd "/usr/sbin/asterisk -cvvvv" $astcontainer
buildah config --created-by "Leif Madsen and Doug Smith" $astcontainer
buildah config --author "leif at redhat dot com" --label name=asterisk-$version-$build $astcontainer

# unmount and commit changes
buildah unmount $astcontainer
buildah commit $astcontainer asterisk

# make this available to our local docker process
buildah push asterisk docker-daemon:nfvpe/asterisk:$version-$build
