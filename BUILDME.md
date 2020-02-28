# Build the VTMaK RTI Executive image

The VTMaK Executive image can be built with the **VTMaK RTI installer** from VTMaK, or with the **skeleton installer** in this repository.

In the first case the VTMaK RTI files are installed in the image and - when built - the image is ready to run.

In the second case only a skeleton directory structure and some necessary (but empty) files are created in the image. No VTMaK files are installed in the image and the files from the VTMaK RTI installer must be mounted into the RTI Executive container afterwards in order to create a functional RTI Executive container.

Perform the following steps to build the VTMaK RTI Executive image.

## Clone repository and drop in VTMaK RTI installer file

Clone this repository to the directory named `${WORKDIR}`.

The installer is located under the directory `${WORKDIR}/vtmak-rtiexec/docker/context`. The name of installer must match with `makRti<version>-linux64-rhe7.tar.gz`, for example `makRti4.5-linux64-rhe7.tar.gz`.

Note the VTMaK RTI version number in the name of the installer, in this example `4.5`.

## Build image

Change into the directory `${WORKDIR}/vtmak-rtiexec/docker`.

Edit the file `.env` and set the VTMaK RTI version number noted before.

Next, build the RTI Executive container image with:

````
docker-compose -f build.yml build
````

The name of the resulting image is:

````
hlacontainers/vtmak-rtiexec:<version>
````

## Notice for the RTI Assistant

VTMaK RTI version 4.5 requires Qt version 5.5.1b (available from MaK site). However, upon execution there is a Null Pointer Exception (NPE) in Qt. No alternate Qt package for 5.5.x is available from yum. As workaround we delete the Qt files under `${VTMAK_RTI_HOME}/lib/gui` and use the latest Qt-base development package, with some other packages that are needed. As far as can be determined this works, except for the display of the Network Map.

Qt 5.5.1 is fairly old and we hope that a newer RTI version will use a more recent Qt version.

