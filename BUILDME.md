# Build the VTMaK RTI Executive image

The VTMaK Executive image can be built with the VTMaK RTI installer from VTMaK, or with the placeholder installer already present in this repository.

In the first case the VTMaK RTI files are installed in the image and - when built - the image is ready to run.

In the second case only a skeleton directory structure and some necessary (but empty) files are created in the image. No VTMaK files are installed in the image and the files from the VTMaK RTI installer must be mounted into the RTI Executive container afterwards in order to create a functional RTI Executive container.

## Build RTI Executive image with the VTMaK RTI installer

Perform the following steps to build the VTMaK RTI Executive image with the RTI installer from VTMaK.

### Obtain the VTMaK RTI executable code

This repository does not contain the VTMaK RTI executable code due to license restrictions. The first step is to obtain the VTMaK RTI installer and licenses from VTMaK, see https://www.mak.com. A free RTI version for two federates can be obtained from this site also.

### Clone repository and drop in VTMaK RTI installer file

Clone this repository to the directory named `${WORKDIR}`.

Copy the VTMaK RTI installer into the directory `${WORKDIR}/vtmak-rtiexec/docker/context` and remove the placeholder installer that is already there. The name of the VTMaK RTI installer is for example `makRti4.5-linux64-rhe7.tar.gz`.

Note the version number `4.5` in the file name.

### Build image

Change into the directory `${WORKDIR}/vtmak-rtiexec/docker`.

Check and if needed adapt the environment variable settings in the file `.env`. Make sure that the version number matches with the number in the installer file name. For example, `4.5` or `4.5f`.

Next, build the RTI Executive container image with:

````
docker-compose -f build.yml build
````

## Build skeleton RTI Exec image with the placeholder installer

Perform the following steps to build a skeleton VTMaK RTI Executive image with the placeholder installer. Note again that the resulting image is not executable since the VTMaK files are missing. These files need to be mounted in the container.

### Clone repository

Clone this repository to the directory named `${WORKDIR}`.

### Build the image

Change into the directory `${WORKDIR}/vtmak-rtiexec/docker`.

Check and if needed adapt the environment variable settings in the file `.env`. For example, set the version number.

Next, build the **skeleton** RTI Executive container image with:

````
docker-compose -f build.yml build
````

### Run skeleton RTI Executive container

An example on how to run the skeleton VTMaK RTI Executive container is provided under the examples directory in this repository. We assume in the example that the VTMaK RTI (including the RTI Executive ) is installed on the host filesystem under the directory `RTI_HOME`. The directory `RTI_HOME` is mounted into the skeleton RTI Executive container to create a functional RTI Executive container, as shown in the composition below:

````
version: '3'

services:
 xserver:
  image: ${REPOSITORY}xserver
  ports:
  - "8080:8080"
 
# Make sure to delete the Qt files from ${RTI_HOME}/lib/gui (see Dockerfile)

 rtiexec:
  image: ${REPOSITORY}vtmak-rtiexec:${VTMAK_VERSION}
  volumes:
  - ${RTI_HOME}:/usr/local/makRti${VTMAK_VERSION}
  environment:
  - DISPLAY=${DISPLAY}
  ports:
  - "4000:4000"
  - "5000:5000"
````

## Notice for the RTI Assistant

VTMaK RTI version 4.5 requires Qt version 5.5.1b (available from MaK site). However, upon execution there is a Null Pointer Exception (NPE) in Qt. No alternate Qt package for 5.5.x is available from yum. As workaround we delete the Qt files under `${RTI_HOME}/lib/gui` and use the latest Qt-base development package, with some other packages that are needed. As far as can be determined this works, except for the display of the Network Map.

Qt 5.5.1 is fairly old and we hope that a newer RTI version will use a more recent Qt version.

