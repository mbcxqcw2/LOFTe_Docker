# NOTES:
Author: C. Walker @ 16/11/2022
This docker environment contains software necessary for analysing LOFT-e data.
On Charlie's machine, this git repository is stored at: /Users/c.walker/LOFTe_Docker/

---

# DEPENDENCIES INSTALLED:
I.e. the software this Dockerfile installs:

- CUDA (more info to come)
- C++11
- numpy
- astropy
- LOFTe_parseVex: https://github.com/mbcxqcw2/LOFTe_parseVex (and dependencies)
- LOFTe_vdifil: https://github.com/mbcxqcw2/LOFTe_vdifil (and dependencies)
- baseband: https://github.com/mhvk/baseband (and dependencies)
- sigpyproc: https://github.com/ewanbarr/sigpyproc (and dependencies)
- presto: https://github.com/scottransom/presto (and dependencies)

---

# 1) INSTRUCTIONS FOR BUILDING AN IMAGE:

1.1) To build this dockerfile into a docker image, run: 

```
>docker build -t <name:tag> .
```

where `<name:tag>` is the name:tag you wish to call the image.

1.2) To find the created image, run:

```
>docker images

```

1.3) To turn the created image into a singularity image, run: 

```
>docker run -v /var/run/docker.sock:/var/run/docker.sock -v <your output dir>:/output --privileged -t --rm singularityware/docker2singularity <image name>
```

where `<your output dir>` is the place where you want to store the singularity image.

---

# 2) INSTRUCTIONS FOR RUNNING AN IMAGE:


2.1) To use the created image with docker, run: 

```
>docker run --rm -ti <image name> bash
```

where `<image name>` is the name of your created image.

2.2) To mount directories while using the image with docker, run: 

```
>docker run --rm -ti -v <LOCATION>/:<LOCATION>/:... <image name> bash
```

2.3) To run the singularity image in a shell, do:

```
>singularity shell --nv -B <data location>:/data <singularity image name>
```

where `<data location>` is the path to a directory containing the data which you wish to process, and `<singularity image name>` is the name of the singularity image created in step 1.3.

---

# 3) INSTRUCTIONS FOR FILTERBANKING e-MERLIN `.VDIF` DATA USING AN IMAGE:

3.1) Within the image, navigate to the mounted directory containing the data you wish to process, e.g.:

```
>cd /data/
```
(assuming a singularity image run using step 2.3.)

3.2) Open ipython, generate a filterbank header file, split the .vdif file into separate polarisations, and exit ipython, e.g.:

```
>ipython
>import vdifil_headers as vh
>import vdifil_splitter as vs
>vh.make_vdifil_header('<vdif_file.vdif>','<vex_file.vex>','<header_filename.dat>')
>vs.split_vdif_file('<vdif_file.vdif>')
>exit()
```
where `<vdif_file.vdif>` is the .vdif file to be filterbanked, `<vex_file.vex>` is the observation's corresponding .vex file, and `<header_filename.dat>` is the name of the header file which will be built. The input .vdif file will be split into two separate polarisations with the names `<vdif_file_pol0.vdif>` and `<vdif_file_pol1.vdif>`. For more information on the .vdif header and splitting software, see the LOFTe_vdifil package linked in the list of dependencies.

3.3) Run the filterbanking software, e.g.:

```
>vdifil -a <vdif_file_pol0.vdif> -b <vdif_file_pol1.vdif> -o /data/<filterbank_filename.fil> -c <header_filename.dat> -s 
```
where `<filterbank_filename.fil>` is the filename of the filterbank file which you wish to create. For more information on the filterbanking software, see the LOFTe_vdifil package linked in the list of dependencies.
