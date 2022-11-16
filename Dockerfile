#NOTES
#Author: C. Walker @ 16/11/2022
#This docker contains software necessary for analysing LOFT-e data.
#To build it into an image, run: >docker build -t <name:tag> .
#where <name:tag> is the name:tag you wish to call the image.
#To find the created image, run: >docker images
#To use the created image, run: >docker run --rm -ti <image name> bash
#where <image name is the name of your created image.
#To mount directories while running the image, run: >docker run --rm -ti -v <LOCATION>/:<LOCATION>/:... <image name> bash
#To turn the created image into a singularity image, run: >docker run -v /var/run/docker.sock:/var/run/docker.sock -v <your output dir>:/output --privileged -t --rm singularityware/docker2singularity <image name>
#where <your output dir> is the place where you want to store the singularity image.


FROM ubuntu

###################################
#Install necessary system packages#
###################################

WORKDIR /
RUN apt-get update
RUN apt-get -y install cmake
RUN apt-get -y install git

#Declare python version
FROM python:3.9.7

#Install and upgrade pip
RUN pip install --upgrade pip




###########################
#Install required packages#
###########################

#baseband by Marten van Kerkwijk
RUN git clone https://github.com/mhvk/baseband
RUN pip install -e baseband/

###########
#Finish up#
###########

#force reinstall jupyter, ipython so it contains necessary packages
RUN pip install ipython --force-reinstall
RUN pip install notebook --force-reinstall
