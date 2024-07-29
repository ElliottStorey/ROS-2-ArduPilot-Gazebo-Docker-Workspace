FROM osrf/ros:humble-desktop-full
SHELL ["/bin/bash", "-c"] 

RUN useradd -m user && \
    usermod -aG sudo user && \
    echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER user

# guide: https://ardupilot.org/dev/docs/ros2-gazebo.html

WORKDIR /home/user

# install ardupilot dependencies
RUN sudo apt install -y default-jre && \
    git clone --recurse-submodules https://github.com/ardupilot/Micro-XRCE-DDS-Gen.git && \
    cd Micro-XRCE-DDS-Gen && \
    ./gradlew assemble
ENV PATH=$PATH:/home/user/Micro-XRCE-DDS-Gen/scripts

# install ardupilot
RUN git clone --recurse-submodules https://github.com/ardupilot/ardupilot.git && \
    cd ardupilot && \
    ./waf configure && \
    USER=user Tools/environment_install/install-prereqs-ubuntu.sh -y && \
    ./waf clean

# install gazebo sim
ENV GZ_VERSION=garden
RUN sudo wget -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg https://packages.osrfoundation.org/gazebo.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    sudo apt update && \
    sudo apt install -y gz-garden

# create ROS 2 workspace
RUN source /opt/ros/humble/setup.bash && \
    mkdir -p ros2_ws/src && \
    cd ros2_ws && \
    colcon build && \
    echo "source /home/user/ros2_ws/install/setup.bash" >> /home/user/.bashrc

WORKDIR /home/user/ros2_ws

# import ROS 2 ardupilot, ardupilot_gz
RUN vcs import --input  https://raw.githubusercontent.com/ArduPilot/ardupilot/master/Tools/ros2/ros2.repos --recursive src && \
    vcs import --input https://raw.githubusercontent.com/ArduPilot/ardupilot_gz/main/ros2_gz.repos --recursive src

# install dependencies
RUN sudo apt update && \
    rosdep update && \
    source /opt/ros/humble/setup.bash && \
    rosdep install --from-paths src --ignore-src -r -y

# build packages
RUN source install/setup.bash && colcon build

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["sleep", "infinity"]