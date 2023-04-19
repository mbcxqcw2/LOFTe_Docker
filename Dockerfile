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


#FROM ubuntu:16.04
FROM nvidia/cuda:11.2.0-devel-ubuntu18.04

MAINTAINER Charles Walker "cwalker@mpifr-bonn.mpg.de"

#Declare a timezone for when we update apt
#Adapted from: https://dev.to/grigorkh/fix-tzdata-hangs-during-docker-image-build-4o9m

ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

###################################
#Install necessary system packages#
###################################

#Make sure we are in the main working directory...
WORKDIR /

#update apt-get
RUN apt-get update -y

#install other packages
RUN apt-get -y install cmake
RUN apt-get -y install git
RUN apt-get -y install gcc

#gfortran for tempo, psrchive, dspsr
#RUN apt-get update
#RUN apt-get -y install gfortran

#fftw (for PSRCHIVE)
RUN apt-get -y install libfftw3-3
RUN apt-get -y install libfftw3-bin
RUN apt-get -y install libfftw3-dev
RUN apt-get -y install libfftw3-single3

#fitsio (for DSPSR)
RUN apt-get -y install libcfitsio-dev

####################################################
#Install python version 3.9, necessary for baseband#
####################################################
#FROM python:3.9.7

#code adapted from: https://stackoverflow.com/questions/70866415/how-to-install-python-specific-version-on-docker
#and: https://dev.to/grigorkh/fix-tzdata-hangs-during-docker-image-build-4o9m
#and: https://stackoverflow.com/questions/56135497/can-i-install-python-3-7-in-ubuntu-18-04-without-having-python-3-6-in-the-system

RUN apt-get install -y curl

RUN apt update && \
    apt install --no-install-recommends -y build-essential software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt install --no-install-recommends -y python3.9 python3.9-dev python3.9-distutils && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Register the version in alternatives (and set higher priority to 3.7)
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2

# Upgrade pip to latest version
RUN curl -s https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3 get-pip.py --force-reinstall && \
    rm get-pip.py

###################################
#Install necessary python packages#
###################################

#numpy
RUN pip install numpy

#matplotlib
RUN pip install matplotlib

#pyqt5 (for ipython gui backend)
RUN pip install pyqt5

#baseband by Marten van Kerkwijk
RUN git clone https://github.com/mhvk/baseband
RUN pip3 install baseband/

#sigpyproc by Ewan Barr
RUN pip install git+https://github.com/telegraphic/sigpyproc

#PRESTO by Scott Ransom
RUN git clone https://github.com/scottransom/presto
#note: we don't really need to install all of PRESTO, just add the python directory to our pythonpath
ENV PYTHONPATH="${PYTHONPATH}/presto/python"

#LOFTe_parseVex for parsing .vex files
RUN git clone https://github.com/mbcxqcw2/LOFTe_parseVex

#Add location of LOFTe_parseVex to python path
ENV PYTHONPATH="${PYTHONPATH}:/LOFTe_parseVex"

#######################################
#Install vdifil filterbanking software#
#######################################

#Download from github
RUN git clone https://github.com/mbcxqcw2/LOFTe_vdifil

#Enter directory and make
WORKDIR LOFTe_vdifil/
RUN nvcc -o vdifil -std=c++11 vdifil.cu -lcufft

#Add location of vdifil to path
ENV PATH="${PATH}:/LOFTe_vdifil"
#Also add location to python path (for generating headers)
ENV PYTHONPATH="${PYTHONPATH}:/LOFTe_vdifil"

#Return to main directory
WORKDIR /

#########################################
#Install TEMPO2 (necessary for PSRCHIVE)#
#########################################

#Pull tempo2 from: https://bitbucket.org/psrsoft/tempo2/src/master/
#RUN git clone https://bitbucket.org/psrsoft/tempo2.git

#go to tempo2 directory
#WORKDIR tempo2/

#Build according to: https://bitbucket.org/psrsoft/tempo2/src/master/
#RUN ./bootstrap
#RUN cp -r T2runtime /usr/share/tempo2/
#RUN export TEMPO2=/usr/share/tempo2/
#RUN apt-get update
#RUN apt-get install -y gfortran
#RUN ./configure F77=gfortran
#RUN make && make install
#RUN make plugins && make plugins-install

#go back to main directory
#WORKDIR /

######################################
#Install psrcat (needed for PSRCHIVE)#
######################################
#Note: realised this due to a T2Generator error, see: https://sourceforge.net/p/psrchive/bugs/429/

#Pull psrcat from: https://www.atnf.csiro.au/people/pulsar/psrcat/download.html
#RUN wget https://www.atnf.csiro.au/people/pulsar/psrcat/downloads/psrcat_pkg.tar.gz

#Untar
#RUN tar -xzvf psrcat_pkg.tar.gz

#Change directory to psrcat
#WORKDIR psrcat_tar/

#make
#RUN ./makeit

#back to main directory
#WORKDIR /

#####################################
#Install PSRCHIVE (needed for DSPSR)#
#####################################
#Clues to make this work came from: https://github.com/ewanbarr/psrchive-docker/blob/master/Dockerfile~

#pull psrchive
#See: https://psrchive.sourceforge.net/current/
#RUN git clone git://git.code.sf.net/p/psrchive/code psrchive

#change directory to psrchive
#WORKDIR psrchive/

#buld psrchive
#ENV PATH $PATH:/psrchive/install/bin
#ENV C_INCLUDE_PATH $C_INCLUDE_PATH:/psrchive/install/include
#ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/psrchive/install/lib

#RUN ./bootstrap
#ENV EXPORT CC=gcc
#ENV EXPORT FC=gfortran
#RUN ./configure --prefix /psrchive/install F77=gfortran
#RUN make
#RUN make check
#RUN make install
#RUN echo "Predictor::default = tempo2" >> .psrchive.cfg
#RUN echo "Predictor::policy = default" >> .psrchive.cfg

#WORKDIR /


################
##Install DSPSR#
################
#
##pull DSPSR
##See: https://dspsr.sourceforge.net/current/
#RUN git clone git://git.code.sf.net/p/dspsr/code dspsr
#
##RUN ls
#
##############################################################################################
##checkout the vdif devel version from https://dspsr.sourceforge.net/manuals/dspsr/vdif.shtml#
##############################################################################################
#
##change to DSPSR directory
#WORKDIR dspsr/
#
#RUN ls
#RUN git pull
#RUN git checkout vdif-devel
#
#########################################################
##create a backends.list file for compiling dspsr.      #
##See: https://dspsr.sourceforge.net/current/build.shtml#
##Note: I think we only need sigproc for filterbanking  #
#########################################################
#
#RUN echo "sigproc fits" >> backends.list
#
##compile
#RUN ./bootstrap
#RUN ./configure
#RUN make
#RUN make install
#
##change directory back to main one
#WORKDIR /
#RUN ls

############
#Finish up#
###########

#force reinstall jupyter, ipython so it contains necessary packages
RUN pip install ipython --force-reinstall
RUN pip install notebook --force-reinstall
