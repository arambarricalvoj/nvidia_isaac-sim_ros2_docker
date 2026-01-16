#!/bin/bash
tilix -a session-add-right -t "ROS2 Jazzy Docker Container" -x "bash -c './run_ros2.sh; exec bash'"
./run_nis.sh