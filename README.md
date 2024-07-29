# ROS 2 ArduPilot Gazebo Docker Workspace

Docker is a tool that helps you package applications and their dependencies into a single, portable unit called a container. This container orchestrates a local workspace (with GUI support) for drone simulation using ROS 2, ArduPilot, and Gazebo Sim.

## Getting Started 

### Installation

In order to run this container you will need docker installed.

* [Windows](https://docs.docker.com/windows/started)
* [Mac](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

### Usage

```shell
docker compose up -d && docker compose exec workspace bash
```

#### Volumes

* `ros2_src` - File location to access ROS 2 packages within workspace.