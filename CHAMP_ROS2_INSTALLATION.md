# CHAMP ROS2 Installation Guide

## 🎉 Good News!

The CHAMP team has **officially released a ROS2 port** on the `ros2` branch!

**Repository**: https://github.com/chvmp/champ  
**Branch**: `ros2`  
**Tested on**: Ubuntu 22.04 - ROS2 Humble  

---

## ✅ ROS2 Port Status

### What's Working ✓

- ✅ libchamp library fully ported
- ✅ RViz-only demo (visualization without hardware)
- ✅ Gazebo simulation with teleoperation
- ✅ Gazebo with SLAM (uses slam_toolbox)
- ✅ Gazebo with Nav2 autonomous navigation
- ✅ TF2 transformations
- ✅ ROS2 controllers

### What's Not Yet Done ✗

- ✗ Velocity smoother (in development)
- ✗ Code cleanup/refactoring
- ✗ Real hardware robot testing
- ✗ Setup-Assistant (GUI configuration tool)
- ✗ Pre-configured robot packages (Anymal, Mini Cheetah, etc. need porting)

---

## 🚀 Installation Instructions

### Prerequisites

- Ubuntu 22.04 or compatible
- ROS2 Humble installed
- Git with recursive clone support
- ~5GB free disk space

### Step 1: Install rosdep

```bash
sudo apt install -y python3-rosdep
rosdep update
```

### Step 2: Clone ROS2 CHAMP

```bash
# Navigate to your workspace src directory
cd <your_workspace>/src

# Clone the ROS2 CHAMP branch (IMPORTANT: use -b ros2)
git clone --recursive https://github.com/chvmp/champ -b ros2

# Clone the ROS2 teleop package
git clone https://github.com/chvmp/champ_teleop -b ros2

# Return to workspace root
cd ..
```

### Step 3: Install Dependencies

```bash
rosdep install --from-paths src --ignore-src -r -y
```

This will install all required ROS2 packages and system dependencies.

### Step 4: Build Workspace

```bash
cd <your_workspace>

# Build using colcon (NOT catkin_make!)
colcon build --symlink-install

# Source the installation
source install/setup.bash
```

**Note**: Use `--symlink-install` for faster development iteration - changes to Python files take effect immediately.

### Step 5: Verify Installation

```bash
# Check if packages are found
ros2 pkg list | grep champ

# Expected output:
# champ
# champ_base
# champ_bringup
# champ_gazebo
# champ_msgs
# champ_navigation
# champ_teleop
# champ_config
# champ_description
```

---

## 🎮 Running CHAMP ROS2 Demos

### Demo 1: RViz Visualization Only

**Best for**: First-time testing, no simulation/hardware needed.

```bash
# Terminal 1: Launch the base driver with RViz
ros2 launch champ_config bringup.launch.py rviz:=true

# Terminal 2: Launch teleoperation
ros2 launch champ_teleop teleop.launch.py

# Use arrow keys to control the robot
```

### Demo 2: Gazebo Simulation

**Best for**: Testing without physical robot.

```bash
# Start Gazebo with the robot
ros2 launch champ_config gazebo.launch.py
```

The robot will be standing still initially.

### Demo 3: Gazebo + Teleoperation

**Best for**: Interactive simulation testing.

```bash
# Terminal 1: Launch Gazebo
ros2 launch champ_config gazebo.launch.py

# Terminal 2: Launch teleoperation
ros2 launch champ_teleop teleop.launch.py

# Use arrow keys to control the robot in simulation
```

### Demo 4: SLAM Mapping

**Best for**: Creating maps while walking the robot around.

```bash
# Terminal 1: Launch SLAM
ros2 launch champ_config slam.launch.py rviz:=true

# Terminal 2: Launch teleoperation  
ros2 launch champ_teleop teleop.launch.py

# Walk the robot around the area to create a map
# Click "2D Nav Goal" in RViz and drag to set navigation targets

# Terminal 3: Save the map when done
cd <your_workspace>/src/champ/champ_config/maps
ros2 run nav2_map_server map_saver_cli -f my_map
```

The map will be saved as `my_map.pgm` (image) and `my_map.yaml` (metadata).

### Demo 5: Autonomous Navigation

**Best for**: Navigation using pre-built maps.

```bash
# Terminal 1: Launch navigation
ros2 launch champ_config navigate.launch.py rviz:=true

# Terminal 2: (Optional) Launch teleoperation for manual override
ros2 launch champ_teleop teleop.launch.py

# In RViz:
# - Set "2D Pose Estimate" to tell the robot where it is
# - Click "2D Nav Goal" and drag to set destination
# Robot will autonomously navigate using Nav2
```

---

## 🐳 Installation in Your Docker Container

If you're using the provided Docker setup, here's how to install CHAMP ROS2:

### Enter the Container

```bash
docker exec -it champ_ros2 bash
```

### Install CHAMP ROS2

```bash
# Navigate to workspace
cd /ws/src

# Clone ROS2 CHAMP
git clone --recursive https://github.com/chvmp/champ -b ros2
git clone https://github.com/chvmp/champ_teleop -b ros2

# Install dependencies
cd /ws
rosdep install --from-paths src --ignore-src -r -y

# Build
colcon build --symlink-install

# Source
source install/setup.bash

# Verify
ros2 pkg list | grep champ
```

### Run Demos in Docker

```bash
# Make sure X11 display is set
export DISPLAY=:0

# Run a demo
ros2 launch champ_config bringup.launch.py rviz:=true
```

---

## 🔧 Directory Structure

After installation, your workspace will have:

```
<workspace>/
├── src/
│   ├── champ/                          # Main CHAMP framework
│   │   ├── champ/                      # Core library
│   │   ├── champ_base/                 # Base controller
│   │   ├── champ_bringup/              # Launch files
│   │   ├── champ_config/               # Default config
│   │   ├── champ_description/          # URDF files
│   │   ├── champ_gazebo/               # Gazebo plugin
│   │   ├── champ_msgs/                 # Custom messages
│   │   ├── champ_navigation/           # Nav2 config
│   │   └── champ_teleop/               # Teleoperation
│   ├── champ_teleop/                   # Separate repo for teleop
│   └── ...
├── build/                              # Build artifacts
├── install/                            # Installed packages
└── log/                                # Build logs
```

---

## 📋 Configuration

### Robot Configuration

Configure your robot in:

```
<workspace>/src/champ/champ_config/
```

Key files:
- `champ.urdf.xacro` - Robot description/URDF
- `gait/gait.yaml` - Gait parameters
- `config/locomotion.yaml` - Locomotion config
- `launch/bringup.launch.py` - Bringup configuration

### Gait Parameters (`champ_config/gait/gait.yaml`)

```yaml
gait_parameters:
  # Robot dimensions
  hip_distance_y: 0.06
  hip_distance_x: 0.1
  hip_distance_z: 0.0

  # Movement
  max_linear_velocity_x: 0.5  # m/s
  max_linear_velocity_y: 0.3  # m/s
  max_angular_velocity_z: 1.57  # rad/s

  # Stance and swing
  stance_duration: 0.25  # seconds on ground
  leg_swing_height: 0.04  # meters above ground
  robot_walking_height: 0.2  # distance hip to ground
```

---

## 🆘 Troubleshooting

### "Package 'champ_config' not found"

**Cause**: Not cloned with `-b ros2` flag or not built yet.

**Solution**:
```bash
# Verify you cloned with ros2 branch
cd <workspace>/src/champ
git branch

# Should show: * ros2

# If not, switch:
git checkout ros2
git pull

# Then rebuild
cd <workspace>
colcon build
source install/setup.bash
```

### "Cannot locate rosdep definition"

**Cause**: Some dependencies don't have ROS2 packages yet.

**Solution**: This is expected for partial ROS2 port. Continue anyway:
```bash
rosdep install --from-paths src --ignore-src -r -y
# Will install what it can and skip unavailable packages
```

### RViz/Gazebo not displaying

**Cause**: X11 display not configured.

**Solution**:
```bash
# Set display
export DISPLAY=:0

# Grant Docker access to display
xhost +local:docker

# Then run demos
ros2 launch champ_config bringup.launch.py rviz:=true
```

### Build errors with missing files

**Cause**: Incomplete clone (missing recursive submodules).

**Solution**:
```bash
cd <workspace>/src/champ
git submodule update --init --recursive

cd <workspace>
colcon build --symlink-install
```

### "colcon: command not found"

**Cause**: colcon not installed.

**Solution**:
```bash
source /opt/ros/humble/setup.bash
# colcon should be available now

# If not:
sudo apt install -y python3-colcon-common-extensions
```

---

## 🚀 Next Steps

1. **Run a demo**: Start with RViz demo (Demo 1)
2. **Explore code**: Look at `champ_base/` for main control logic
3. **Modify configuration**: Edit `champ_config/gait/gait.yaml`
4. **Test with Gazebo**: Run Gazebo demo (Demo 3)
5. **Integrate with Nav2**: Try autonomous navigation (Demo 5)

---

## 📚 Additional Resources

- **CHAMP GitHub**: https://github.com/chvmp/champ
- **ROS2 Humble Docs**: https://docs.ros.org/en/humble/
- **Nav2 Documentation**: https://navigation.ros.org/
- **Gazebo Sim**: https://gazebosim.org/

---

## ❤️ Contributing

The ROS2 port is still in development! You can help:

- Test with your hardware and report issues
- Port pre-configured robot packages to ROS2
- Improve code quality and documentation
- Add features (velocity smoother, etc.)

Check: https://github.com/chvmp/champ/issues

---

## License

CHAMP is licensed under BSD-3-Clause. See the repository for details.

---

**Last Updated**: September 2026  
**ROS2 Branch**: Active & Tested  
**Status**: ✅ Ready for development and simulation
