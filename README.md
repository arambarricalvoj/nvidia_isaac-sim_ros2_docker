
# nvidia_isaac-lab_3.0.0-EA_ros2_docker (DISTRIBUTED)
Under development! https://github.com/isaac-sim/IsaacLab/issues/7732

# Isaac Lab version
``3.0.0-EA``
<br>

# Isaac Sim version
``6.1.0``
<br>

<!-- # ROS2 version
``ROS2 Jazzy Desktop``
<br> -->

# Official instructions
```bash
git clone git@github.com:isaac-sim/IsaacLab.git --branch v3.0.0-EA
cd IsaacLab
```

Build Docker image: 
```bash
./docker/container.py start
```

Run Docker imager:
```bash
./docker/container.py enter base
```

Run Isaac Sim inside Docker container:
```bash
./_isaac_sim/runapp.sh
```

<!--
# Installation and execution
<!--Follow the instructions in the “nis-6.1.0-distributed” branch.
Then, follow these steps:


## Download Isaac Lab image (includes installation of Isaac Sim 5.1.0 within the image)
```bash
sudo chmod u+x download_images.sh
./download_images.sh
```
<br>

# Run container
```bash
sudo chmod u+x run_nil.sh
./run_nil.sh
```

# Run Isaac Sim inside the container
```bash
cd _isaac_sim/
./runapp.sh
```
Wait until Isaac Sim is completely loaded. Ignore "not responding" messages, it will take some time, so be patient ;).
<br>

# Run Isaac Lab test inside the container
```bash
cd workspace/isaaclab/
./isaaclab.sh -p scripts/tutorials/00_sim/log_time.py --headless
```

This example only verifies that the Isaac Lab installation is working correctly:
- Isaac Sim starts in headless mode
- The simulation engine runs without errors
- Simulated time advances correctly
- You can run a Python script within the environment
- Communication between Isaac Lab ↔ Python is configured correctly

To do this, create an empty world, start the simulation, and print the simulated time at each step.

The simulation time is recorded in ``/workspace/isaaclab/logs/docker_tutorial/log.txt``. To verify that it is actually working:
```bash
cat /workspace/isaaclab/logs/docker_tutorial/log.txt
```
<br>

# Bibliography 
https://isaac-sim.github.io/IsaacLab/v3.0.0-EA/source/setup/installation/index.html#installation-method-container



# Outdated bibliography
https://isaac-sim.github.io/IsaacLab/main/source/deployment/docker.html

https://catalog.ngc.nvidia.com/orgs/nvidia/containers/isaac-lab?version=2.3.2

https://docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/index.html

https://docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/install_ros.html

-->