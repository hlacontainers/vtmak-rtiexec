# VTMaK RTI Executive image
The VTMaK RTI Executive (rtiexec) is an application that manages one or more federation executions within the VTMaK RTI. For example, it keeps track of joined federates and maintains information about the publication and subscription interests of individual federates. The RTI Executive is a required application when using the VTMaK RTI.

This repository contains the files and instructions to build and run a Docker container image for the VT MaK RTI Executive. **This repository does not include any VTMaK files**. The VTMaK RTI installer and license keys must be acquired from the vendor. A free version of the VTMaK RTI for two federates can be downloaded from the vendor website. For more information about the VTMaK RTI, see https://www.mak.com.

By default a **skeleton** Docker container image is built from the files in this repository. A skeleton container image does not include any VTMaK proprietary files. These files must be mounted into the RTI Executive container at run-time in order to create a functional RTI Executive container.

For the instructions to build a skeleton or a complete VTMaK RTI Executive container image see [BUILDME](BUILDME.md).

The simplest way to start the VTMaK RTI Executive container is with the following `docker-compose.yml` file,  where in this example:

- The VTMaK RTI Executive container image is a skeleton image. 
- The VTMaK RTI is installed on the host file system under the directory `${VTMAK_RTI_HOME}`.

````
version: '3'

services:
 xserver:
  image: ${REPOSITORY}xserver
  ports:
  - "8080:8080"
 
# Make sure to delete the Qt files from ${VTMAK_RTI_HOME}/lib/gui (see Dockerfile)

 rtiexec:
  image: ${REPOSITORY}vtmak-rtiexec:${VTMAK_VERSION}
  volumes:
  - ${VTMAK_RTI_HOME}:/usr/local/makRti
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
VTMAK_VERSION=skeleton

# X DISPLAY for the RTI Exec (required when using the RTI Assistant)
DISPLAY=xserver:0

# Host installation directory of the VTMaK RTI (TAILOR THIS TO YOUR OWN ENVIRONMENT)
# For example:
# - on Linux: VTMAK_RTI_HOME=/usr/local/makRti4.5
# - on Windows: VTMAK_RTI_HOME=C:\MAK\makRti4.5
VTMAK_RTI_HOME=/usr/local/makRti4.5
````

The environment file should be used to tailor the composition to the local infrastructure, such as the address of the X Server, or the installation directory of the VTMaK RTI,

Port 4000 is the default port on which the RTI Executive listens and port 5000 is the default port on which the Forwarder listens for connection requests from a Local RTI Component (LRC).

By default the RTI Assistant is enabled. Therefore an X Display is required.

Also note the text about the Qt files under `${VTMAK_RTI_HOME}/lib/gui`. The Qt files shipped with the RTI do work in the container image. As work-around the Qt files must be removed in order to force the RTI Executive to use the latest Qt version that is installed in the container image. More information can be found in the build instructions and Dockerfile.

## Container synopsis

````
vtmak-rtiexec:<version> <options>
````

Container options are passed on to the RTI Executive. See the RTI user manual for more information on command line options.

Ports:

`4000` : RTI Executive listen port.

`5000` : RTI Forwarder listen port.

## Environment variables

The VTMaK RTI Executive has many configuration settings, stored in the file `rid.mtl`.  A small subset of these can be changed via environment variables. These are listed in the table below and for the details we refer to the VTMaK RTI user documentation.

The following environment variables are supported

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

