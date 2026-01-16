
# nvidia_isaac-sim_4.5.0_ros2_docker (DISTRIBUTED)

<!-- Arrancar
./runapp.sh --enable omni.isaac.ros2_bridge -->

**Isaac Sim runs with warnings (``check warning.md``, for instance, to add a RTX Lidar you may need to add some configuration files. At the moment, this issue has not been resolved, and the .md file is only available in Spanish)**

Run NVIDIA Isaac Sim (NIS) 4.5.0 in a Docker container with ROS2 bridge already set up and communicating with another Docker container running the ROS2 Humble application.
Please, first af all check NIS_4-5-0 requiremente here: https://docs.isaacsim.omniverse.nvidia.com/4.5.0/installation/requirements.html. 

In this case, the Isaac Sim Docker image is the official one provided by NVIDIA, so no Dockerfile is included. However, the ROS2 image, although based on the official OSRF Docker image, requires additional configuration (the inclusion of a fastdds.xml profile) to enable communication with Isaac Sim. For this reason, a custom Dockerfile is provided for the ROS 2 container.

A link to my Docker Hub is provided as a backup for both images, you never know what third parties might do with their repositories ;) [https://hub.docker.com/r/arambarricalvoj/nis_ros2](https://hub.docker.com/r/arambarricalvoj/nis_ros2):
- (soon available) Official NIS 4.5.0 image in my Docker Hub: ``docker pull arambarricalvoj/nis_ros2:nis-4.5.0``
- (soon available) Official ROS2 Jazzy image in my Docker Hub: ``docker pull arambarricalvoj/nis_ros2:ros-jazzy-desktop-full``
- Adapted ROS2 Jazzy image in my Docker Hub: ``docker pull arambarricalvoj/nis_ros2:ros-jazzy-desktop-full-nis`` 

If you meet all the requirements, you can jump directly to [Download and run with bash scripts](#download-and-run-with-bash-scripts) to start developing!

NOTE: NIS 4.5.0 officially works with ROS2 Humble, but since the bridge is used to communicate topics, services, and actions, it will work in almost all cases with ROS2 Jazzy. The steps presented in this file correspond to ROS2 Humble, but the scripts correspond to Jazzy, so modify them according to your needs or preferences.
<br>

# Specifications
This repository has been run with the following host specifications:

OS: ``Ubuntu 24.04.X LTS``<br>
RAM: ``32 GB``<br>
Processor: ``13th Gen Intel® Core™ i7-13650HX × 20``<br>
Graphics card: ``NVIDIA GeForce RTX 4060 Laptop GPU``<br>
Graphics card memory: ``8 GB``<br>
NVIDIA-SMI dirvers version: ``570.195.03``<br>
CUDA version: ``12.8``<br>
Needed disk space: ``25 GB`` (rounded up)<br>

*It should work in previous releases as 20.04 and 22.04.
<br>

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
This step is needed as Docker inherits X Server (GUI) from the host, any of the following will fail in order to run NIS with NVIDIA GPU in Docker:
```bash
sudo prime-select intel
sudo prime-select on-demand
```
<br>

# Isaac Sim version
``4.5.0``
<br>

# ROS2 version
``ROS2 Humble Desktop``
<br>

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
<br>

# Download images image
```bash
docker pull osrf/ros:humble-desktop-full
docker pull nvcr.io/nvidia/isaac-sim:4.5.0
```
<br>

# Run containers
Allow running graphic interfaces in the container:
```bash
xhost +local:docker
```
Run the NIS container with the needed configuration:
```bash
xhost +local:docker
docker run --name nis-4.5.0-bare \
           --entrypoint bash \
           -it \
           --runtime=nvidia \
           --gpus all \
           -e RMW_IMPLEMENTATION=rmw_fastrtps_cpp \
           -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/isaac-sim/exts/isaacsim.ros2.bridge/humble/lib \
           -e NVIDIA_VISIBLE_DEVICES=all \
           -e NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute \
           -e "ACCEPT_EULA=Y" \
           --rm \
           --network=host \
           -e "PRIVACY_CONSENT=Y" \
           -e DISPLAY=$DISPLAY \
           -v /tmp/.X11-unix/:/tmp/.X11-unix/ \
           -v ~/docker/isaac-sim/cache/kit:/isaac-sim/kit/cache:rw \
           -v ~/docker/isaac-sim/cache/ov:/root/.cache/ov:rw \
           -v ~/docker/isaac-sim/cache/pip:/root/.cache/pip:rw \
           -v ~/docker/isaac-sim/cache/glcache:/root/.cache/nvidia/GLCache:rw \
           -v ~/docker/isaac-sim/cache/computecache:/root/.nv/ComputeCache:rw \
           -v ~/docker/isaac-sim/logs:/root/.nvidia-omniverse/logs:rw \
           -v ~/docker/isaac-sim/data:/root/.local/share/ov/data:rw \
           -v ~/docker/isaac-sim/documents:/root/Documents:rw \
           nvcr.io/nvidia/isaac-sim:4.5.0
```
The volume ```-v ~/docker/isaac-sim/documents:/root/Documents:rw``` is intended to be the working directory for NIS files.

Run the ROS2 container with the needed configuration:
```bash
xhost +local:docker
docker run -e DISPLAY=$DISPLAY \
           -e USER=$USER \
           -e NVIDIA_VISIBLE_DEVICES=all \
           -e NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute \
           --runtime=nvidia \
           -v /tmp/.X11-unix/:/tmp/.X11-unix/ \
           --device /dev/dri:/dev/dri \
           -it \
           --rm \
           --network=host \
           --gpus all \
           --name ros2_humble \
           ros:humble-desktop-full_nis
```

REMEMBER: if you want to share a folder between the host and the container, mount it adding the next flag to the previous command:
```bash
-v HOST_PATH:PATH_IN_CONTAINER
```
```bash
-v ~/Documents/isaac_sim/PROJECT_ID:~/PROJECT_ID
```
<br>

# Run Isaac Sim inside the container
If this command is included when running the container, ROS2 bridge will fail. That's because the container with ROS2 packages must be started first, and then Isaac Sim.
Once the container is running, type next line in the container:
```bash
./runapp.sh
```
Wait until Isaac Sim is completely loaded. Ignore "not responding" messages, it will take some time, so be patient ;).

If GUI fails to open, ensure that host's ```$DISPLAY``` variable is set to ``:0`` (and then rerun the NIS Docker image):
```bash
echo $DISPLAY 
```
<br>

# Download/build Docker images and run with bash scripts 

You can automatically execute the above process using the ```download_images.sh```, ```build_ros2.sh``` ```run_nis.sh```, ```run_ros2.sh``` and ```run.sh``` scripts.

Add execution permissions:
```bash
chmod u+x download_images.sh build_ros2.sh run_nis.sh run_ros2.sh run.sh
```

Download NIS image:
```bash
./download_images.sh
```

Build or download ROS2 Docker image adapted to NIS:
  - Build:
    ```bash
    ./build_ros2.sh
    ```
  
  - Download:
    ```bash
    docker pull arambarricalvoj/nis_ros2:ros-jazzy-desktop-full-nis
    ```

Run ROS2:
```bash
./run_ros2.sh
```

If you are using Tilix to manage multiple terminals on the same screen, open a Tilix terminal and run the following command. The NIS container will automatically open on the left and the ROS2 container on the right.
```bash
./run.sh
```
You can install Tilix easily:
```bash
sudo apt update && sudo apt install tilix -y
```
<br>

# (Recommended solution, optional) Matching host user UID/GID with the NVIDIA Isaac Sim Docker container
When running Isaac Sim inside Docker, files created inside the mounted `projects/` directory inherit the **UID and GID of the user inside the container**.  
NVIDIA's Isaac Sim images typically run as a user with:
- **UID = 1234**
- **GID = 1234**

If the host user has a different UID/GID (e.g., the default 1000:1000), files created by Isaac Sim will appear on the host as belonging to an *unknown user*, causing:
- permission denied errors  
- inability to edit or delete files without `sudo`  
- Git refusing to stage or commit files  
- VS Code failing to save changes  
- broken workflows when mixing host and container operations  

To avoid these issues, the most robust solution is to **create a host user whose UID and GID match those of the Isaac Sim container**. This ensures that files created inside Docker appear on the host as belonging to a real user, with full read/write access and without requiring elevated privileges.

---

## 1. Create a host user with UID/GID 1234

```bash
sudo groupadd -g 1234 isaac_sim
sudo useradd -m -u 1234 -g 1234 isaac_sim
sudo passwd isaac_sim
```

## 2. (Optional but recommended) Copy your existing environment
If you want the new user to have the same shell configuration, ROS setup, VS Code settings, etc.:
```bash
sudo groupadd -g 1234 isaac_sim
sudo useradd -m -u 1234 -g 1234 isaac_sim
sudo passwd isaac_sim # Change the password
```

### 3. (If you are using a VNC server, see the [`vnc`](https://github.com/arambarricalvoj/nvidia_isaac-sim_ros2_docker/tree/vnc) branch)
If your workflow relies on a VNC session, ensure that the new user becomes the one owning the graphical session.  
To do this:

**Enable automatic login for the new user** so that the X session on `:0` belongs to them.    
   Edit the GDM configuration file (or configure it through *Settings*, as shown in the [`vnc`](https://github.com/arambarricalvoj/nvidia_isaac-sim_ros2_docker/tree/vnc) branch):

   ```bash
   sudo nano /etc/gdm3/custom.conf
   ```

  Under the [daemon] section, set:
  ```
  AutomaticLoginEnable=true
  AutomaticLogin=isaac_sim
  ```

  Then restart GDM or reboot:
  ```
  sudo systemctl restart gdm3
  ```

  Or:
  ```
  sudo reboot
  ```
<br>

# Check ROS2 Bridge along both containers
On NIS, ``Create > ROS2 Assets > Nova Carter`` and click ``Play``:
![Create Nova Carter on NIS](img/nova_carter.png)
![Nova Carter Play on NIS](img/nova_carter_play.png)
![Nova Carter Play2 on NIS](img/nova_carter_play2.png)


On ROS2 container, run:
```bash
ros2 topic list
```
You will see the topics used by NIS. If you stop the simulation or exit the NIS container and run `ros2 topic list`, you will not see as many topics as before.

![No topics on simulation stopped](img/no_topics.png)
![Topics on simulation started](img/topics.png)
<br>

# Bibliography 
https://docs.isaacsim.omniverse.nvidia.com/4.5.0/installation/index.html

https://docs.isaacsim.omniverse.nvidia.com/4.5.0/installation/install_ros.html

# Outdated bibliography
https://docs.omniverse.nvidia.com/isaacsim/latest/installation/install_container.html

https://omniverse-content-production.s3-us-west-2.amazonaws.com/Assets/Isaac/Documentation/Isaac-Sim-Docs_2022.2.1/isaacsim/latest/install_ros.html

https://catalog.ngc.nvidia.com/orgs/nvidia/containers/isaac-sim

https://github.com/NVIDIA-Omniverse/IsaacSim-dockerfiles


