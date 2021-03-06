[modeline]: # ( vim: set tabstop=4 shiftwidth=4 expandtab smartindent fenc=utf-8 spell spl=en: )

# astricon2018
Notes and files for AstriCon 2018 Day Of Learning

## Topology

We have 4 virtual nodes:

* openshift-master
* openshift-node-1
* openshift-node-2
* openshift-infra-node-3

Nodes 1 and 2 are regular compute nodes. Node 3 will act as our infrastructure
node (inbound traffic to the compute nodes). The master will host the web
console and the API for the nodes.

The Master, Node 1 and Node 2 will host the GlusterFS storage cluster.

## Virtual Machine Spin Up

We'll use our `base-infra-bootstrap` repo and the inventory files provided by
this repository to spin up our virtual machines. These will sit as the
foundation for our OpenShift deployment.

    mkdir -p ~/src/astricon2018
    cd ~/src/astricon2018 && \
        git clone https://github.com/leifmadsen/astricon2018 ./configs
    cd ~/src/github/redhat-nfvpe && \
        git clone https://github.com/redhat-nfvpe/base-infra-bootstrap
    cd base-infra-bootstrap

    # instantiate our virtual hosts
    ansible-playbook -i ../configs/inventory/virthost \
        -e "@../configs/inventory/vars.yml" playbooks/virt-host-setup.yml

    # make sure NetworkManager is installed, enabled, started
    ansible -i ../configs/inventory/inventory.yml -m raw -s \
        --sudo -a "yum install NetworkManager -y ; systemctl enable NetworkManager.service ; systemctl start NetworkManager.service" all

If all has gone well, you should now have all 4 virtual machines up and
running.

## Deploying OpenShift Origin 3.9

We'll now deploy our OpenShift Origin 3.9 onto the virtual machines.

    ansible-playbook -i ../configs/inventory/inventory.yml \
        playbooks/prerequisites.yml \
        playbooks/deploy_cluster.yml

### Post-Deployment Configuration

There are a few things we'll need to do post-deployment in order to get logged
into the system.

    ssh centos@192.168.3.16     # openshift-master
    sudo htpasswd -b /etc/origin/master/htpasswd admin welcome

You can now make sure you can login to the web console with your
username/password. Go to https://console.astricon.home.61will.space:8443 (or
whatever your hostnames are setup for). You may need to add this to your
`/etc/hosts` file if you don't have real DNS setup.

We also need to make sure we give ourselves cluster wide permissions so we can
eventually push into the cluster from our development machine.

    oc adm policy add-cluster-role-to-user cluster-admin admin

## Setup APB Development Machine

The APB development machine is where we'll do our APB development. We'll push
our catalog item(s) into our OpenShift Origin setup so that things are
available in the service catalog.

### Install and setup Docker

    ssh centos@192.168.3.20     # apb-devel.astricon.home.61will.space
    sudo groupadd docker
    sudo usermod -aG docker centos
    newgrp docker
    sudo yum install docker git vim-enhanced -y
    sudo systemctl enable docker.service
    sudo systemctl start docker.service

### Install `oc` command

    curl -#SL https://github.com/openshift/origin/releases/download/v3.9.0/openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz -O
    tar zxvf openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz
    mkdir -p ~/.local/bin
    mv openshift-origin-client-tools-v3.9.0-191fece-linux-64bit/oc ~/.local/bin/
    rm -rf openshift-origin-client-tools-v3.9.0-191fece-linux-64bit*

### Install `apb` and `ansible` command

    sudo yum -y install wget
    sudo su -c 'wget https://copr.fedorainfracloud.org/coprs/g/ansible-service-broker/ansible-service-broker-latest/repo/epel-7/group_ansible-service-broker-ansible-service-broker-latest-epel-7.repo -O /etc/yum.repos.d/ansible-service-broker.repo'
    sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    sudo yum -y install apb ansible

### Login to OpenShift

    oc login https://master.astricon.home.61will.space:8443 -u admin -p welcome --insecure-skip-tls-verify=true

## APB Creation

    # get route of Ansible Service Broker (ASB)
    oc project openshift-ansible-service-broker
    oc get route

    # APB configuration
    $ apb config
    Broker namespace [default: openshift-automation-service-broker]: openshift-ansible-service-broker
    Broker resource URL [default: /apis/servicecatalog.k8s.io/v1beta1/clusterservicebrokers/]: 
    Broker route name [default: broker]: asb-1338
    clusterservicebroker resource name [default: openshift-automation-service-broker]: ansible-service-broker
    Broker route suffix [default: osb]: ansible-service-broker

    git clone https://github.com/leifmadsen/astricon2018
    cd astricon2018/apb/asterisk15-apb
    apb bundle prepare
    oc project openshift
    oc new-build --binary=true --name asterisk15-apb
    oc start-build --follow --from-dir . asterisk15-apb

# Create a new APB

    # create an APB
    ansible-galaxy init --type=apb asterisk15-apb
    cd asterisk15-apb

    # prepare
    apb bundle prepare

    # create build (only needed once)
    oc project openshift
    oc new-build --binary=true --name asterisk15-apb

    # build
    oc start-build --follow --from-dir . asterisk15-apb

    # reload ansible service broker
    apb broker bootstrap

    # reload the catalog listing
    apb catalog relist

    # view catalog items
    apb broker catalog

    # build registry
    apb registry add openshift --namespaces default,openshift --type local_openshift
