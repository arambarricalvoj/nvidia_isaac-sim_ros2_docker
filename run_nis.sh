xhost +local:docker
docker run --name nis-6.1.0-bare \
           --entrypoint bash \
           -it \
           --runtime=nvidia \
           --gpus all \
           -e DISPLAY=$DISPLAY \
           -e "ACCEPT_EULA=Y" \
           --rm --network=host \
           -e "PRIVACY_CONSENT=Y" \
           -e RMW_IMPLEMENTATION=rmw_fastrtps_cpp \
           -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/isaac-sim/exts/isaacsim.ros2.bridge/jazzy/lib \
           -e NVIDIA_VISIBLE_DEVICES=all \
           -e NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute \
           -v /tmp/.X11-unix/:/tmp/.X11-unix/ \
           -v ~/docker/isaac-sim/cache/main:/isaac-sim/.cache:rw \
           -v ~/docker/isaac-sim/cache/computecache:/isaac-sim/.nv/ComputeCache:rw \
           -v ~/docker/isaac-sim/logs:/isaac-sim/.nvidia-omniverse/logs:rw \
           -v ~/docker/isaac-sim/config:/isaac-sim/.nvidia-omniverse/config:rw \
           -v ~/docker/isaac-sim/data:/isaac-sim/.local/share/ov/data:rw \
           -v ~/docker/isaac-sim/pkg:/isaac-sim/.local/share/ov/pkg:rw \
           -v ./projects:/isaac-sim/projects:rw \
           -u 1234:1234 \
           nvcr.io/nvidia/isaac-sim:6.1.0