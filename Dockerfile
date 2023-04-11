# Download base image ubuntu 22.04
FROM ubuntu:22.04


# Install git and C-compiler and latest go needed for geth
RUN apt-get -y update && \
    apt-get -y install git \
    build-essential \
    make \
    gcc  \
    wget && \
    wget  https://go.dev/dl/go1.20.2.linux-amd64.tar.gz && \
    tar -xvf go1.20.2.linux-amd64.tar.gz && \
    mv go /usr/local  


# Configure Go
ENV GOROOT /usr/local/go 
ENV GOPATH /go 
ENV PATH $GOROOT/bin:$PATH

# Download and install geth version 
# Change this line to clone forked version of geth
RUN git clone https://github.com/ethereum/go-ethereum.git
RUN cd go-ethereum && \
    make geth && \
    cp ./build/bin/geth /usr/local/bin/

# Expose ports and entrypoint
EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["geth"]
