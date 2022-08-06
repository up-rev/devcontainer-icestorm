FROM ubuntu:18.04 as dev

ARG DEBIAN_FRONTEND=noninteractive

#passwords as arguments so they can be changed
ARG DEV_PW=password
ARG JENKINS_PW=jenkins

ENV LC_CTYPE en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apt-get update && apt-get install -y \
  # IceStorm and friends
  bison \
  build-essential \
  clang \
  flex \
  gawk \
  git \
  graphviz \
  libboost-all-dev \
  libeigen3-dev \
  libffi-dev \
  libftdi-dev \
  libreadline-dev \
  mercurial \
  pkg-config \
  python \
  python3 \
  python3-pip \
  python3-setuptools \
  python3-dev \
  qt5-default \
  tcl-dev \
  xdot \
  # Icarus Verilog and friends
  autoconf \
  bison \
  flex \
  g++ \
  gcc \
  git \
  gperf \
  gtkwave \
  make \
  wget \
  && rm -rf /var/lib/apt/lists/* 


  # Install new Cmake (Ubuntu 18.04 repos only go up to 3.10.2)
RUN cd /tmp && \
    wget https://cmake.org/files/v3.23/cmake-3.23.2.tar.gz && \
    tar -xzvf cmake-3.23.2.tar.gz && \ 
    cd cmake-3.23.2 && \
    ./bootstrp && \
    make && \
    make install


  # icestorm
RUN git clone --recursive https://github.com/cliffordwolf/icestorm.git icestorm && \
    cd icestorm && \
    make clean && \
    make -j$(nproc) && \
    make install && cd - && \
    rm -r icestorm 

# arachne-pnr
RUN git clone --recursive https://github.com/cseed/arachne-pnr.git arachne-pnr \
    && cd arachne-pnr && make clean && make -j$(nproc) && make install && cd - && rm -r arachne-pnr \
    # nextpnr
    && git clone --recursive https://github.com/YosysHQ/nextpnr nextpnr \
    && cd nextpnr && cmake -DARCH=ice40 -DBUILD_GUI=OFF -DCMAKE_INSTALL_PREFIX=/usr/local . \
    && make -j$(nproc) && make install && cd - && rm -r nextpnr \
    # yosys
    && git clone --recursive https://github.com/cliffordwolf/yosys.git yosys \
    && cd yosys && make clean && make yosys-abc \
    && make -j$(nproc) && make install && cd - && rm -r yosys \
    # iverilog
    && git clone --recursive https://github.com/steveicarus/iverilog.git iverilog \
    && cd iverilog && autoconf && ./configure && make clean \
    && make -j$(nproc) && make install && cd - && rm -r iverilog \
    # verilator
    && git clone --recursive https://github.com/ddm/verilator.git verilator \
    && cd verilator && autoconf && ./configure && make clean \
    && make -j$(nproc) && make install && cd - && rm -r verilator


RUN pip3 install -U mrtutils

# Add user dev to the image
RUN adduser --quiet dev && \
    echo "dev:$DEV_PW" | chpasswd && \
    chown -R dev /home/dev 

CMD [ "/bin/bash" ]


######################################################################################################
#                           Stage: jenkins                                                           #
######################################################################################################
FROM dev as jenkins

ARG JENKINS_PW

ENV LC_CTYPE en_US.UTF-8
ENV LANG en_US.UTF-8


#install jenkins dependencies
RUN apt install -qq -y --no-install-recommends openjdk-8-jdk  openssh-server ca-certificates
RUN adduser --quiet jenkins && \
    echo "jenkins:$JENKINS_PW" | chpasswd && \
    mkdir /home/jenkins/.m2 && \
    mkdir /home/jenkins/jenkins && \
    chown -R jenkins /home/jenkins 
#JENKINS END

# Setup SSH server
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

ENV NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]