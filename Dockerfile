FROM uprev/base:ubuntu-22.04 as dev


RUN apt-get update && apt-get install -y \
  # IceStorm and friends
  bison \
  clang \
  flex \
  gawk \
  graphviz \
  libboost-all-dev \
  libeigen3-dev \
  libffi-dev \
  libftdi-dev \
  libreadline-dev \
  libssl-dev \
  mercurial \
  pkg-config \
  python3-dev \
  tcl-dev \
  xdot \
  # Icarus Verilog and friends
  autoconf \
  bison \
  flex \
  gperf \
  gtkwave \
  openssl \
  && rm -rf /var/lib/apt/lists/* 


  # Install new Cmake (Ubuntu 18.04 repos only go up to 3.10.2)
RUN cd /tmp && \
    wget https://cmake.org/files/v3.23/cmake-3.23.2.tar.gz && \
    tar -xzvf cmake-3.23.2.tar.gz && \ 
    cd cmake-3.23.2 && \
    ./bootstrap && \
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
    && cd arachne-pnr && make clean && make -j$(nproc) && make install && cd - && rm -r arachne-pnr 

# nextpnr
RUN git clone --recursive https://github.com/YosysHQ/nextpnr nextpnr \
    && cd nextpnr && cmake -DARCH=ice40 -DBUILD_GUI=OFF -DCMAKE_INSTALL_PREFIX=/usr/local . \
    && make -j$(nproc) && make install && cd - && rm -r nextpnr 

# yosys
RUN git clone --recursive https://github.com/cliffordwolf/yosys.git yosys \
    && cd yosys && make clean && make yosys-abc \
    && make -j$(nproc) && make install && cd - && rm -r yosys 

    # iverilog
RUN git clone --recursive https://github.com/steveicarus/iverilog.git iverilog \
    && cd iverilog && sh autoconf.sh && ./configure && make clean \
    && make -j$(nproc) && make install && cd - && rm -r iverilog 

#     # verilator
# RUN git clone --recursive https://github.com/ddm/verilator.git verilator \
#     && cd verilator && autoconf && ./configure && make clean \
#     && make -j$(nproc) && make install && cd - && rm -r verilator


CMD [ "/bin/bash" ]
