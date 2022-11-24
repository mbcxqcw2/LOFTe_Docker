# NOTES:
Author: C. Walker @ 16/11/2022
This docker environment contains software necessary for analysing LOFT-e data.
On Charlie's machine, this git repository is stored at: /Users/c.walker/LOFTe_Docker/

---

# INSTRUCTIONS FOR USE:

1) To build this dockerfile into an image, run: 

```
>docker build -t <name:tag> .
```

where `<name:tag>` is the name:tag you wish to call the image.

2) To find the created image, run:

```
>docker images
```

3) To use the created image, run: 

```
>docker run --rm -ti <image name> bash
```

where `<image name>` is the name of your created image.

4) To mount directories while running the image, run: 

```
>docker run --rm -ti -v <LOCATION>/:<LOCATION>/:... <image name> bash
```

5) To turn the created image into a singularity image, run: 

```
>docker run -v /var/run/docker.sock:/var/run/docker.sock -v <your output dir>:/output --privileged -t --rm singularityware/docker2singularity <image name>
```

where `<your output dir>` is the place where you want to store the singularity image.

6) To run this singularity image in a shell, do:

```
>singularity shell --nv -B <data location>:/data <singularity image name>
```

where `<data location>` is the path to a directory containing the data which you wish to process, and `<singularity image name>` is the name of the singularity image created in step 5.
