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


FROM ubuntu:16.04

###################################
#Install necessary system packages#
###################################

#Make sure we are in the main working directory...
WORKDIR /

#install packages
RUN apt-get update -y
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

#Declare python version
FROM python:3.9.7

#Install and upgrade pip
RUN pip install --upgrade pip


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
RUN pip install -e baseband/

#########################################
#Install TEMPO2 (necessary for PSRCHIVE)#
#########################################

#Pull tempo2 from: https://bitbucket.org/psrsoft/tempo2/src/master/
RUN git clone https://bitbucket.org/psrsoft/tempo2.git

#go to tempo2 directory
WORKDIR tempo2/

#Build according to: https://bitbucket.org/psrsoft/tempo2/src/master/
RUN ./bootstrap
RUN cp -r T2runtime /usr/share/tempo2/
RUN export TEMPO2=/usr/share/tempo2/
RUN apt-get update
RUN apt-get install -y gfortran
RUN ./configure F77=gfortran
RUN make && make install
RUN make plugins && make plugins-install

#go back to main directory
WORKDIR /

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
