![Build Status](https://img.shields.io/docker/cloud/build/hlacontainers/vtmak-rtiexec)
![Pull](https://img.shields.io/docker/pulls/hlacontainers/vtmak-rtiexec)

# VTMaK RTI Executive image
The VTMaK RTI Executive (rtiexec) is an application that manages one or more federation executions within the VTMaK RTI. For example, it keeps track of joined federates and maintains information about the publication and subscription interests of individual federates. The RTI Executive is a required application when using the VTMaK RTI.

This repository contains the files and instructions to build and run a Docker container image for the VT MaK RTI Executive. The VTMaK RTI installer can be downloaded from the vendor site. This version is free for two federate, but license keys to use more than two federates must be acquired from the vendor. For more information about the VTMaK RTI, see https://www.mak.com.

For the instructions to build a VTMaK RTI Executive container image see [BUILDME](BUILDME.md).

Once the image is built, the simplest way to start the VTMaK RTI Executive container is with the following `docker-compose.yml` file:

````
version: '3'

services:
 xserver:
  image: ${REPOSITORY}xserver
  ports:
  - "8080:8080"
 
 rtiexec:
  image: ${REPOSITORY}vtmak-rtiexec:${VTMAK_VERSION}
  environment:
  - DISPLAY=${DISPLAY}
  ports:
  - "4000:4000"
  - "5000:5000"
````

and using the following `.env` file:

````
# Repository prefix
REPOSITORY=hlacontainers/

# VTMaK version
VTMAK_VERSION=4.6b

# X DISPLAY for the RTI Exec (required when using the RTI Assistant)
DISPLAY=xserver:0
````

The environment file should be used to tailor the composition to the local infrastructure, such as the address of the X Server.

Port 4000 is the default port on which the RTI Executive listens and port 5000 is the default port on which the Forwarder listens for connection requests from a Local RTI Component (LRC).

By default the RTI Assistant is enabled. Therefore an X Display is required.

## Container synopsis

````
vtmak-rtiexec:<version> <options>
````

Container options are passed on to the RTI Executive. See the RTI user manual for more information on command line options.

Ports:

`4000` : RTI Executive listen port.

`5000` : RTI Forwarder listen port.

## Environment variables

The VTMaK RTI Executive has many configuration settings, stored in the file `rid.mtl`.  A subset of these can be changed via environment variables. A number of these are listed in the table below and for the complete list see the `start.sh` file. For further information on these settings refer to the VTMaK RTI user documentation.

| Environment variable              | Default           | Description                                                  | Required |
| --------------------------------- | ----------------- | ------------------------------------------------------------ | -------- |
| ``MAK_RTI_RID_FILE``              | -                 | File path name of an alternate RID file. Can be used to override the RID file used by the rtiexec. The alternate RID file must be provided through a volume mount. | No       |
| ``MAK_RTI_NOTIFY_LEVEL``          | ``2``             | The level of detail provided in console/log output. Can be a value in the range 0--4 with 0 being no detail and 4 the most detail. | No       |
| ``MAK_RTI_LOG_FILE_DIRECTORY``    | Working directory | The directory into which an rtiexec log file will be written. | No       |
| ``MAK_RTI_RTIEXEC_LOG_FILE_NAME`` | -                 | The name of the log file written by the rtiexec. This needs to be defined for a log file to be written (into ``MAK_LOGFILE_DIR``). | No       |
| ``MAKLMGRD_LICENSE_FILE``         | -                 | Address of MaK License Manager. Format is ``[<port>]@<host>``. The port number is optional (default: 27000). | No       |
| ``RTI_ASSISTANT_DISABLE``         | -                 | To disable the RTI Assistant, set this environment to any value. If unset, set ``DISPLAY`` to an X Server display. | No       |
| ``DISPLAY``                       | -                 | The X Server display for the RTI Assistant.                  | No       |

## RTI RID file

The RTI RID file used by the RTI Executive has the following default settings:

- The RID file settings correspond to the ``RTI_forceFullCompliance`` setting, with the exception of the `RTI_fomDataTransportTypeControl` setting. The `RTI_fomDataTransportTypeControl` is set to the value `2` so that all FOM data is sent reliable regardless of the FOM transportation type.

- The RID file is configured to let the RTI Executive perform licensing (``RTI_rtiExecPerformsLicensing `` is set to ``1``).

Note that all settings for each individual federate application must be compatible with the RTI Executive RID file setting. This is the case if the LRC image is used.

## RTI Assistant and RTI licenses

If the RTI Assistant is used and there are no RTI licenses configured for the RTI Executive, a license error is displayed by the RTI Assistant, blocking the Forwarder from starting. Only when the error popup windows are closed the Forwarder is started and an LRC can connect.

So, check the X Display UI for these messages and close them.

## Provide an alternate VTMaK RID file

The environment variables listed above are for a small number of VTMaK RTI Executive and Forwarder settings. To change the entire RID file, just mount an alternate, but identically named RID file at `/usr/local/makRti${VERSION}/rid.mtl` or use the environment variable `MAK_RTI_RID_FILE` to specify another location.

