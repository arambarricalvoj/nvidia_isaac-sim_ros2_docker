# nvidia_isaac-sim_ros2_docker
Run NVIDIA Isaac Sim (NIS) in a Docker container with ROS2 and ROS2 bridge already set up.

<!-- At the moment, only NIS 4.X.X versions over Ubuntu 22.04 LTS and ROS2 Humble -->

Choose your branch!
- [nis-4.2.0](https://github.com/arambarricalvoj/nvidia_isaac-sim_ros2_docker/tree/nis-4.2.0): NVIDIA Isaac Sim 4.2.0
- [nis-4.5.0](https://github.com/arambarricalvoj/nvidia_isaac-sim_ros2_docker/tree/nis-4.5.0): NVIDIA Isaac Sim 4.5.0
- [nis-4.5.0-distributed](https://github.com/arambarricalvoj/nvidia_isaac-sim_ros2_docker/tree/nis-4.5.0-distributed): NVIDIA Isaac Sim 4.5.0 in one container and ROS2 in another container, both connected via the network.
- [nis-5.1.0-distributed](https://github.com/arambarricalvoj/nvidia_isaac-sim_ros2_docker/tree/nis-5.1.0-distributed): NVIDIA Isaac Sim 5.1.0 in one container and ROS2 in another container, both connected via the network.
- [nil-2.3.2](https://github.com/arambarricalvoj/nvidia_isaac-sim_ros2_docker/tree/nil-2.3.2): NVIDIA Isaac Sim 5.1.0 and Isaac Lab 2.3.2 in one container and ROS2 in another container, both connected via the network.
- [nis-6.1.0-distributed](https://github.com/arambarricalvoj/nvidia_isaac-sim_ros2_docker/tree/nis-6.1.0-distributed): *Under development!*, NVIDIA Isaac Sim 6.1.0 in one container and ROS2 in another container, both connected via the network.
- [nil-3.0.0-EA](https://github.com/arambarricalvoj/nvidia_isaac-sim_ros2_docker/tree/nil-3.0.0-EA): *Under development!*, NVIDIA Isaac Sim 6.1.0 and Isaac Lab 3.0.0-EA in one container and ROS2 in another container, both connected via the network.

“Distributed” branches: a container for Isaac Sim with the ROS2 bridge, but with the ROS2 application running in another container and both containers communicating with each other. The goal is to make it easier to update the versions of the container dependencies and reduce the total disk space occupied. This way of working is what NVIDIA proposes with versions +5.X.X.

**Reference branches**:  
The distributed branches are the main reference for this repository. The recommended reference order is:
1. [nil-2.3.2](https://github.com/arambarricalvoj/nvidia_isaac-sim_ros2_docker/tree/nil-2.3.2)

2. [nis-5.1.0-distributed](https://github.com/arambarricalvoj/nvidia_isaac-sim_ros2_docker/tree/nis-5.1.0-distributed)

3. [nis-4.5.0-distributed](https://github.com/arambarricalvoj/nvidia_isaac-sim_ros2_docker/tree/nis-4.5.0-distributed)

<!-- ***I am working on creating branches of “distributed” working versions, that is, a container for Isaac Sim with the ROS2 bridge, but with the ROS2 application running in another container and both containers communicating with each other. The goal is to make it easier to update the versions of the container dependencies and reduce the total disk space occupied. This way of working is what NVIDIA proposes with versions 5.X.X... soon available ;)*** -->