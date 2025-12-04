
# nvidia_isaac-sim_5.1.0_ros2_docker

under development...

<!-- 
    Check if your system is compatible with Isaac Sim:

./isaac-sim.compatibility_check.sh --/app/quitAfter=10 --no-window

./isaac-sim.compatibility_check.sh

-->


<!--Start Isaac Sim with native livestream mode:

./runheadless.sh -v 

Start Isaac Sim with GUI:

./runapp.sh-->


<!-- 
esta imagen trae ros2 bridge? https://docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/install_container.html

Respuesta breve: Sí, la imagen oficial de Isaac Sim en contenedor incluye soporte para el ROS2 bridge, pero no se activa automáticamente: debes lanzar los paquetes o extensiones correspondientes dentro del contenedor
-->



--



<!--**Isaac Sim runs with warnings (``check warning.md``, for instance, to add a RTX Lidar you may need to add some configuration files. At the moment, this issue has not been resolved, and the .md file is only available in Spanish)**

Run NVIDIA Isaac Sim (NIS) 4.5.0 in a Docker container with ROS2 Humble and ROS2 bridge already set up.
Please, first af all check NIS_4-5-0 requiremente here: https://docs.isaacsim.omniverse.nvidia.com/4.5.0/installation/requirements.html. 

I share the Dockerfile in this repository. I hope it helps you!

In order to build the image, you can either follow the steps manually or run the bash script ``build.sh``. Make sure to meet all the prerrequisites.<br>
In order to run the container, you can run it manually as shown below or run the bash script ``run.sh``.<br>

# Specifications
This repository has been run with the following host specifications:

OS: ``Ubuntu 24.04.X LTS``<br>
RAM: ``32 GB``<br>
Processor: ``13th Gen Intel® Core™ i7-13650HX × 20``<br>
Graphics card: ``NVIDIA GeForce RTX 4060 Laptop GPU``<br>
Graphics card memory: ``8 GB``<br>
Needed disk space: ``20 GB``<br>

*It should work in previous releases as 20.04 and 22.04.

# Prerequisites
- NVIDIA Drivers installation: https://ubuntu.com/server/docs/nvidia-drivers-installation<br>
GPU drivers version must be 535.129.03 or later, check it with:
```bash
nvidia-smi
```

- NVIDIA Isaac Sim Requirements: https://docs.isaacsim.omniverse.nvidia.com/4.5.0/installation/requirements.html
Please ensure you meet the minimum requirements for NIS 4.5.0 before proceeding.

- Docker installation and executing without sudo:
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```
```bash
# Post-install steps for Docker
sudo groupadd docker # Create group
sudo usermod -aG docker $USER # Add current user to docker group
newgrp docker # Log in docker group
```
```bash
#Verify Docker installation
docker run hello-world
```

- NVIDIA Container Toolkit installation:
```bash
# Configure the repository
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
  && \
    sudo apt-get update

# Install the NVIDIA Container Toolkit packages
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

# Configure the container runtime
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Verify NVIDIA Container Toolkit
docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
```

- Generate NGC API Key: https://docs.nvidia.com/ngc/ngc-overview/index.html#generating-api-key
- Log in to NGC:
```bash
docker login nvcr.io
```
```bash
Username: $oauthtoken
Password: <Your NGC API Key>
WARNING! Your password will be stored unencrypted in /home/username/.docker/config.json.
Configure a credential helper to remove this warning. See
credentials-store
Login Succeeded
```

- Activate NVIDIA GPU X Server (host running GUI with NVIDIA GPU instead of Intel/AMD one):
```bash
sudo prime-select nvidia
sudo reboot
```
This step is needed as Docker inherits X Server (GUI) from the host, any of the following will
fail in order to run NIS with NVIDIA GPU in Docker:
```bash
sudo prime-select intel
sudo prime-select on-demand
```

# Isaac Sim version
``4.5.0``

# ROS2 version
``ROS2 Humble Desktop``

# Docker version
``Client: Docker Engine - Community``<br>
``Version:           27.3.1``<br>
``API version:       1.47``<br>
``Go version:        go1.22.7``<br>
``Git commit:        ce12230``<br>
``Built:             Fri Sep 20 11:40:59 2024``<br>
``OS/Arch:           linux/amd64``<br>
``Context:           default``<br>

``Server: Docker Engine - Community``<br>
`Engine:`<br>
` Version:          27.3.1`<br>
` API version:      1.47 (minimum version 1.24)`<br>
`Go version:       go1.22.7`<br>
`Git commit:       41ca978`<br>
`Built:            Fri Sep 20 11:40:59 2024`<br>
`  OS/Arch:          linux/amd64`<br>
`  Experimental:     false`<br>
` containerd:`<br>
`  Version:          1.7.22`<br>
`  GitCommit:        7f7fdf5fed64eb6a7caf99b3e12efcf9d60e311c`<br>
` runc:`<br>
`  Version:          1.1.14`<br>
 ` GitCommit:        v1.1.14-0-g2c9f560`<br>
 `docker-init:`<br>
  `Version:          0.19.0`<br>
 ` GitCommit:        de40ad0`<br>


# Build image
```bash
docker build -t {IMAGE_NAME}:{TAG} .
```
Example:
```bash
docker build -t nis_ros2:4.5.0-Humble .
```

# Run container
Allow running graphic interfaces in the container:
```bash
xhost +local:docker
```
Run the container with the needed configuration:
```bash
xhost +local:docker
docker run --name isaac-sim \
           --entrypoint bash \
           -it \
           --rm \
           --network=host \
           --gpus all \
           -runtime=nvidia \
           -e DISPLAY=$DISPLAY \
           -e NVIDIA_VISIBLE_DEVICES=all \
           -e NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute \
           -e "ACCEPT_EULA=Y" \
           -e "PRIVACY_CONSENT=Y" \
           -v $HOME/.Xauthority:/root/.Xauthority \
           -v ~/docker/isaac-sim/cache/kit:/isaac-sim/kit/cache:rw \
           -v ~/docker/isaac-sim/cache/ov:/root/.cache/ov:rw \
           -v ~/docker/isaac-sim/cache/pip:/root/.cache/pip:rw \
           -v ~/docker/isaac-sim/cache/glcache:/root/.cache/nvidia/GLCache:rw \
           -v ~/docker/isaac-sim/cache/computecache:/root/.nv/ComputeCache:rw \
           -v ~/docker/isaac-sim/logs:/root/.nvidia-omniverse/logs:rw \
           -v ~/docker/isaac-sim/data:/root/.local/share/ov/data:rw \
           -v ~/docker/isaac-sim/documents:/root/Documents:rw \
           nis_ros2:4.5.0-Humble
```
The volume ```-v ~/docker/isaac-sim/documents:/root/Documents:rw``` is intended to be the working directory for NIS files.

REMEMBER: if you want to share a folder between the host and the container, mount it adding the next flag to the previous command:
```bash
-v HOST_PATH:PATH_IN_CONTAINER
```
```bash
-v ~/Documents/isaac_sim/PROJECT_ID:~/PROJECT_ID
```

# Run Isaac Sim inside the container
If this command is included when running the container, ROS2 bridge will fail. That's because the container with ROS2 packages must be started first, and then Isaac Sim.
Once the container is running, type next line in the container:
```bash
./runapp.sh
```
Wait until Isaac Sim is completely loaded. Ignore "not responding" messages, it will take some time, so be patient ;).

# Build and run with bash scripts 
#build-and-run-with-bash-scripts

You can automatically execute the above process using the ```build.sh``` and ```run.sh``` scripts.

Add execution permissions:
```bash
chmod u+x build.sh run.sh
```

Build:
```bash
./build.sh
```

Run:
```bash
./run.sh
```

# Bibliography (still outdated... needs to be checked in future commits)
https://docs.omniverse.nvidia.com/isaacsim/latest/installation/install_container.html

https://omniverse-content-production.s3-us-west-2.amazonaws.com/Assets/Isaac/Documentation/Isaac-Sim-Docs_2022.2.1/isaacsim/latest/install_ros.html

https://catalog.ngc.nvidia.com/orgs/nvidia/containers/isaac-sim

https://github.com/NVIDIA-Omniverse/IsaacSim-dockerfiles

-->
