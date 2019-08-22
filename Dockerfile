# Build the image
# docker build -t cinguparam --build-arg uid=$(id -u) .

# Run processes in isolated container
# docker run -it --rm --hostname $(hostname)-docker --volume $(pwd):/home/lyly cinguparam bash

# If you have this problem: warning Failed to fetch...
# Try this solution: build again the image cinguparam 

# If you have this problem: warning Failed to create endpoint...
# Try this solution: reboot 

FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
&& apt-get install --no-install-recommends -y parallel sagemath git libxml2-utils mmv bsdmainutils \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

ARG uid=1000
ARG uname=lyly
RUN useradd -u $uid $uname
USER $uname

# Generate database

#CMD cd generateParam && bash genDatabase.sh


# Estimate best attack on parameter sets obtained with indicated POLITIC (Cingulata_BFV, SEAL_BFV, FV_NFLlib). More info on politics in generateParam/defaultParam.sh.

#ENV POLITIC=Cingulata_BFV
#ENV POLITIC=FV_NFLlib
#ENV POLITIC=SEAL_BFV
#CMD cd estimateParam && bash checkSecu.sh ${POLITIC}  && bash sortAttack.sh ${POLITIC}

WORKDIR /home/lyly



