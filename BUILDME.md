# Build the VTMaK RTI Executive image

Perform the following steps to build the VTMaK RTI Executive image.

## Clone repository and drop in VTMaK RTI installer file

Clone this repository to the directory named `${WORKDIR}`.

Replace the placeholder RTI installer (which has a zero size) by the actual RTI installer.

The installer is located under the directory `${WORKDIR}/vtmak-rtiexec/docker/context`. The name of installer must match with `makRti<version>-linux64-rhe8*.tar.gz`, for example `makRti4.6b-linux64-rhe8-20220411.tar.gz`.

Note the VTMaK RTI version number in the name of the installer, in this example `4.6b`.

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
