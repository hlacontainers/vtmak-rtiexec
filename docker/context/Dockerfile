#
# Copyright 2020 Tom van den Berg (TNO, The Netherlands).
# SPDX-License-Identifier: Apache-2.0
#

# Set default for build-time ARGs
ARG VTMAK_VERSION=4.5

########################
# Create base image with data
########################
FROM centos:7 AS base

ARG VTMAK_VERSION

# The MaK RTI files are installed here
ENV RTI_HOME=/usr/local/makRti${VTMAK_VERSION}

# Install Mak RTI
ADD ./makRti${VTMAK_VERSION}-linux64-rhe7.tar.gz /usr/local

# Brute force, remove non-working Qt libs
RUN rm -rf ${RTI_HOME}/lib/gui/libQ*

# Ensure at least directories and setting files are created in case we use a placefolder install file
RUN mkdir -p ${RTI_HOME}/bin ${RTI_HOME}/lib ${RTI_HOME}/data ${RTI_HOME}/include
RUN touch ${RTI_HOME}/rid.mtl

########################
# Create RTI Exec image
########################
FROM centos:7

ARG VTMAK_VERSION

# Workaround issue with DBUS
RUN dbus-uuidgen > /var/lib/dbus/machine-id

# The official MaK Qt package (5.5.1b for this RTI) does not work for CentOS.
# There is a NPE, and Qt 5.5.1 appears fairly outdated -- no packages appear available for yum.
# As workaround we use the lastest Qt-base development, with other packages we need.
# However, no guarentees this will work fully.

# Package net-tools is optional.
RUN yum install -y \
	mesa-libGLU \
	libicu \
	xorg-x11-server-utils \
	xkeyboard-config \
	qt5-qtbase-devel \
	qt5-qtimageformats \
	qt5-qtsvg \
	net-tools \
	python-setuptools
	
RUN easy_install supervisor

# The MaK RTI files are installed here
ENV RTI_HOME=/usr/local/makRti${VTMAK_VERSION}

# Copy relevant files from base (also copy the include dir for derived LRC image)
COPY --from=base $RTI_HOME/bin/		$RTI_HOME/bin/
COPY --from=base $RTI_HOME/lib/		$RTI_HOME/lib/
COPY --from=base $RTI_HOME/data/	$RTI_HOME/data/
COPY --from=base $RTI_HOME/include/	$RTI_HOME/include/
COPY --from=base $RTI_HOME/rid.mtl	$RTI_HOME/rid.mtl

# Set library path in case we want to start the rtiexec from the assistant
ENV LD_LIBRARY_PATH=${RTI_HOME}/lib

# Set RID file
ENV RTI_RID_FILE=$RTI_HOME/rid.mtl

COPY start.sh /root/rtiexec/
WORKDIR /root/rtiexec

COPY supervisord.conf /etc/supervisor/supervisord.conf
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
