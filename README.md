## Vagrant on Mac

### How to setup a VM on Mac with Vagrant?

1. Update Brew: `brew update`
2. Install Vagrant: `brew install vagrant`
3. Install Qemu plugin for Vagrant: `vagrant plugin install vagrant-qemu`
4. Access to the VM in SSH mode: `vagrant ssh`

### Find a box name

To find the box name to use in the Vagrantfile:
1. Go on [https://portal.cloud.hashicorp.com/vagrant/discover?query=](https://portal.cloud.hashicorp.com/vagrant/discover?query=)
2. Set `Provider` to `qemu`
3. Set `Architecture` to the one related to your Mac (`uname -m`)
4. In the search bar, search for the LTS of the OS you want to install (by typing `debian trixie` for instance)