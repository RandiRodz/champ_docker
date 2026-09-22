# Use ROS2 Humble as base image (LTS version)
FROM ros:humble

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=humble
ENV WORKSPACE=/ws

# Install essential dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3-rosdep \
    python3-colcon-common-extensions \
    python3-colcon-mixin \
    ros-${ROS_DISTRO}-desktop \
    ros-${ROS_DISTRO}-gazebo-ros \
    ros-${ROS_DISTRO}-rviz2 \
    ros-${ROS_DISTRO}-nav2-bringup \
    ros-${ROS_DISTRO}-nav2-map-server \
    ros-${ROS_DISTRO}-slam-toolbox \
    ros-${ROS_DISTRO}-teleop-twist-keyboard \
    ros-${ROS_DISTRO}-tf-transformations \
    python3-numpy \
    python3-yaml \
    wget \
    curl \
    nano \
    vim \
    tmux \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
RUN mkdir -p ${WORKSPACE}/src

# Note: Original CHAMP is ROS1-based (uses catkin, roscpp, rospy).
# For ROS2 compatibility, you have two options:
# 1. Clone ROS2-ported CHAMP packages into src/
# 2. Add your own ROS2-compatible packages to src/

# Optionally clone the original CHAMP repo as reference (won't build as-is)
WORKDIR ${WORKSPACE}/src
RUN echo "# CHAMP ROS2 Workspace" > README.md && \
    echo "# Add ROS2-compatible CHAMP packages here" >> README.md

# Install common ROS dependencies for packages
WORKDIR ${WORKSPACE}
RUN rosdep update || true

# Build the workspace (will be empty initially - add packages to src/)
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && \
    if [ "$(ls -A src/)" ]; then colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release; else echo "No packages to build yet. Add ROS2 packages to src/ and rebuild."; fi

# Source the workspace setup in bashrc
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc && \
    echo "source ${WORKSPACE}/install/setup.bash" >> /root/.bashrc

# Set the working directory
WORKDIR ${WORKSPACE}

# Default command
CMD ["/bin/bash"]
