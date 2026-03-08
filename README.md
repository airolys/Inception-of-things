## P3

### Difference between k3s and k3d

- k3s allows to create a cluster directly on a VM
- k3d allows to create a cluster inside a Docker container, no VM required

### App deployment

To test that the app has been well deployed inside its pod:
1. Inside the VM, execute : `sudo kubectl port-forward svc/service-www 8080:80 -n dev`
2. Inside the VM again, from another terminal, execute `curl http://localhost:8080`

It should return `Hello World v1!`

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

## Other sources

- Kubernetes Namespaces: [https://kubernetes.io/docs/tasks/administer-cluster/namespaces/](https://kubernetes.io/docs/tasks/administer-cluster/namespaces/)