#!/usr/bin/env bash

BASE_INFRA_BOOTSTRAP_GIT_REPO="https://github.com/redhat-nfvpe/base-infra-bootstrap"
OPENSHIFT_GIT_REPO="https://github.com/openshift/openshift-ansible"
OPENSHIFT_BRANCH="openshift-ansible-3.9.39-1"
_TOPDIR=`pwd`

echo "-- Create working directory"
if [ ! -d working ]; then
    mkdir working
fi

pushd working
    echo "-- Clone base-infra-bootstrap"
    git clone --depth 1 --branch master ${BASE_INFRA_BOOTSTRAP_GIT_REPO} > /dev/null 2>&1
    pushd base-infra-bootstrap
        ansible-galaxy install -r requirements.yml
    popd

    echo "-- Clone OpenShift ${OPENSHIFT_BRANCH}"
    git clone --depth 1 --branch ${OPENSHIFT_BRANCH} ${OPENSHIFT_GIT_REPO} > /dev/null 2>&1
popd

echo "-- Done."
