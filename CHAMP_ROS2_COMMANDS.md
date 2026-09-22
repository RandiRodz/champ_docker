# CHAMP ROS2 Quick Reference

## Getting Started

After starting the container:

```bash
# Source the ROS2 environment (usually auto-sourced)
source /opt/ros/humble/setup.bash
source /ws/install/setup.bash
```

## Running CHAMP Demos

### 1. Walking Demo in RViz (No Hardware Needed)

**Terminal 1** - Launch the base driver with RViz:
```bash
ros2 launch champ_config bringup.launch.py rviz:=true
```

**Terminal 2** - Launch teleoperation:
```bash
ros2 launch champ_teleop teleop.launch.py joy:=false
```

Then use arrow keys to control the robot movement.

### 2. Gazebo Simulation

Launch the robot in Gazebo:
```bash
ros2 launch champ_config gazebo.launch.py
```

**In another terminal**, launch teleop:
```bash
ros2 launch champ_teleop teleop.launch.py
```

### 3. SLAM (Mapping) Demo

**Terminal 1** - Gazebo simulation:
```bash
ros2 launch champ_config gazebo.launch.py
```

**Terminal 2** - SLAM mapping:
```bash
ros2 launch champ_config slam.launch.py rviz:=true
```

**Terminal 3** - Teleoperation:
```bash
ros2 launch champ_teleop teleop.launch.py
```

Navigate the robot around to create a map. When done:
```bash
ros2 run nav2_map_server map_saver_cli -f ~/map
```

## Useful ROS2 Commands

### Check Active Topics
```bash
ros2 topic list
```

### View Topic Data
```bash
ros2 topic echo /topic_name
```

### View TF Tree
```bash
ros2 run tf2_tools view_frames
```

### Check Node Info
```bash
ros2 node list
```

### View Node Details
```bash
ros2 node info /node_name
```

### RViz2 Visualization
```bash
rviz2
```

### RQT Graph (Node/Topic Visualization)
```bash
rqt_graph
```

## Configuration

### Gait Parameters

Edit gait configuration:
```bash
nano /ws/src/champ/champ_config/config/gait.yaml
```

Key parameters:
- `max_linear_velocity_x` - Forward speed (m/s)
- `max_linear_velocity_y` - Sideways speed (m/s)
- `max_angular_velocity_z` - Rotation speed (rad/s)
- `leg_swing_height` - Swing phase height (m)
- `robot_walking_height` - Hip to ground distance (m)

### Robot Configuration

View current robot config:
```bash
ls /ws/src/champ/champ_config/
```

## Building Custom Robot

Use the setup assistant:
```bash
# Clone the setup assistant
git clone https://github.com/chvmp/champ_setup_assistant.git

# Follow the instructions to generate your robot config
```

## Pre-configured Robots

Install pre-configured robot packages:
```bash
cd /ws/src
git clone https://github.com/chvmp/robots.git
cd ../..
colcon build
source install/setup.bash
```

Available robots:
- AnyMal (ANYmal C)
- Mini Cheetah (MIT Mini Cheetah)
- LittleDog (Boston Dynamics)
- Spot
- SpotMicroAI

Example with specific robot:
```bash
ros2 launch mini_cheetah_config bringup.launch.py rviz:=true
```

## Troubleshooting

### Robot not responding to commands
- Check if base driver is running: `ros2 node list | grep champ`
- Check topics: `ros2 topic list | grep cmd`
- View errors: `ros2 node info /champ_base` and check parameters

### No visualization in RViz
- Ensure X11 display is working
- Run: `export DISPLAY=:0` (or your display number)
- Restart RViz

### Build errors after adding new packages
```bash
source /opt/ros/humble/setup.bash
cd /ws
colcon clean all
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release
source install/setup.bash
```

### Memory issues
Increase Docker memory and try lighter builds:
```bash
colcon build --packages-select package_name  # Build specific package only
```

## Performance Tuning

### Enable Optimization
Rebuild with optimizations:
```bash
cd /ws
colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release -O3
```

### Monitor Performance
```bash
# CPU and memory usage
ros2 run tf2_tools view_frames

# Topic frequency
ros2 topic hz /topic_name

# Topic bandwidth
ros2 topic bw /topic_name
```

## Development Tips

### Create Custom Launch File
```bash
nano /ws/src/champ_config/launch/custom.launch.py
```

### Rebuild After Changes
```bash
cd /ws
colcon build --symlink-install
source install/setup.bash
```

### Enable Debug Output
```bash
ros2 launch champ_config bringup.launch.py rviz:=true log_level:=debug
```

## Additional Resources

- CHAMP GitHub: https://github.com/chvmp/champ
- ROS2 Documentation: https://docs.ros.org/en/humble/
- ROS2 Tutorials: https://docs.ros.org/en/humble/Tutorials.html
- CHAMP Wiki: https://github.com/chvmp/champ/wiki

## Exit Commands

When you're done:

```bash
# Exit ROS nodes (Ctrl+C in each terminal)

# Exit container
exit

# Stop container from host machine
docker-compose stop
```
