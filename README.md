## P3

### Difference between k3s and k3d

- k3s allows to create a cluster directly on a VM
- k3d allows to create a cluster inside a Docker container, no VM required

### App deployment

To test that the app has been well deployed inside its pod:
1. Inside the VM, execute : `sudo kubectl port-forward svc/service-www 8888:80 -n dev`
2. Inside the VM again, from another terminal, execute `curl http://localhost:8888`

It should return `Hello World v{tagVersion}!`

### Custom Docker app image

1. Build image with specific architecture: `docker build --platform linux/arm64 -t rkassel/playground:v{tagVersion} .`
2. Push the image on Docker Hub: `docker push rkassel/playground:v{tagVersion}`

Before pushig the image, you can also test it locally and outside the VM by:
1. Retrieving the image ID after build: `docker image ls`
2. Running it with a port mapping between Docker and the host machine: `docker run -p 8888:8888 {imageId}`
3. Curling the port inside another terminal: `curl http://localhost:8888`

It should return `Hello World v{tagVersion}!`

### Argo CD

To access Argo CD Dashboard from host machine:
1. Setup a forwarding port inside Vagrant file: `config.vm.network "forwarded_port", guest: 8443, host: 8443`
2. Inside the VM, launch: `sudo kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8443:443`
3. Then just access to `http://localhost:8443` from the browser of your host machine

Dashboard credentials:
- Username: always `admin`
- Password: get it by running `sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo` inside the VM

## Bonus

### Increase VM size disk for Mac

These steps need to be done before `vagrant up`.

#### List available boxes

`vagrant box list`

#### Remove the box you want to use

`vagrant box remove {boxName} --provider libvirt --force`

For instance, `vagrant box remove cloud-image/debian-13 --provider libvirt --force`

#### Verify the box has been removed

`vagrant box list`

#### Add the box of your choice manually

`vagrant box add {boxName} --provider libvirt`

For instance, `vagrant box add cloud-image/debian-13 --provider libvirt`

#### Verify the box has been added

`vagrant box list`

#### Find the new box file path

`find ~/.vagrant.d/boxes -name "box.img"`

#### Increase the box size

`qemu-img resize {boxLocation} +30G`

#### Start the VM

`vagrant up`

#### Connect to the VM

`vagrant ssh`

Now, the following steps can done directly inside the Vagrant provisionning script

#### Check size of the parent disk (all new space available)

`lsblk`

#### Check real disk size available

`df -h /`

#### Resize disk size

These steps can be not necessary for modern images as `cloud-image` as they automatically resize depending on the available space.

`sudo growpart /dev/vda 1`
`sudo resize2fs /dev/vda1`

#### Check disk size AFTER

`df -h /`

### Gitlab

#### See space used by services

`sudo kubectl get pvc -A`

#### Apply Gitlab YAML file updates

```
exit
vagrant rsync
vagrant ssh
sudo kubectl delete jobs --all -n gitlab
sudo helm upgrade gitlab gitlab/gitlab -f ./confs/01-gitlab.yaml -n gitlab --force
sudo kubectl get pods -n gitlab 
```

#### See logs related to a pod

`sudo kubectl describe pod -n gitlab [POD_NAME]`

#### Gitlab UI

Create tunnel between the Gitlab UI and the host machine/VM: `sudo kubectl port-forward --address 0.0.0.0 deployment/gitlab-webservice-default -n gitlab 8443:8080` (or 8443:8181)

Get admin password: `udo kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 --decode; echo`

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