#
# Copyright 2020 Tom van den Berg (TNO, The Netherlands).
# SPDX-License-Identifier: Apache-2.0
#

# Set default for build-time ARGs
ARG VTMAK_VERSION=skeleton

########################
# Create base image with data
########################
FROM centos:7 AS base

ARG VTMAK_VERSION

# The MaK RTI files are installed here
ENV RTI_HOME=/usr/local/makRti${VTMAK_VERSION}

# Install Mak RTI
ADD ./makRti${VTMAK_VERSION}-linux64-rhe7.tar.gz /usr/local

# Install Qt 5.6.3
ENV QTDIR=/opt/qt/5.6.3
COPY ./qt-5.6.3-mak-linux-rhentws7-64bit.sh /tmp
RUN echo ${QTDIR} | sh /tmp/qt-5.6.3-mak-linux-rhentws7-64bit.sh
RUN rm -rf ${RTI_HOME}/lib/gui/libQ*
RUN rm -rf ${RTI_HOME}/bin/gui/qplugins
RUN cp -r ${QTDIR}/plugins/ ${RTI_HOME}/bin/gui/qplugins
RUN cp -r ${QTDIR}/lib/* ${RTI_HOME}/lib/gui

# Ensure there is a skeleton structure
RUN mkdir -p ${RTI_HOME}/bin ${RTI_HOME}/lib ${RTI_HOME}/data ${RTI_HOME}/include
RUN touch ${RTI_HOME}/rid.mtl

########################
# Create RTI Exec image
########################
FROM centos:7

ARG VTMAK_VERSION

# Workaround issue with DBUS
RUN dbus-uuidgen > /var/lib/dbus/machine-id

RUN yum install -y \
	mesa-libGLU mesa-libEGL mesa-dri-drivers mesa-filesystem mesa-libGLES mesa-libGLw mesa-libOSMesa \
	libicu \
	xorg-x11-server-utils \
	libpng freetype fontconfig \
	xkeyboard-config \
	nc iproute \
	python-setuptools
	
RUN easy_install supervisor

# The MaK RTI files are installed here
ARG RTI_HOME_FROM=/usr/local/makRti${VTMAK_VERSION}
ENV RTI_HOME=/usr/local/makRti

# Copy relevant files from base (also copy the include dir for derived LRC image)
COPY --from=base $RTI_HOME_FROM/bin/		$RTI_HOME/bin/
COPY --from=base $RTI_HOME_FROM/lib/		$RTI_HOME/lib/
COPY --from=base $RTI_HOME_FROM/data/		$RTI_HOME/data/
COPY --from=base $RTI_HOME_FROM/include/	$RTI_HOME/include/
COPY --from=base $RTI_HOME_FROM/rid.mtl		$RTI_HOME/rid.mtl

# Set library path in case we want to start the rtiexec from the assistant
ENV LD_LIBRARY_PATH=${RTI_HOME}/lib:${RTI_HOME}/lib/gui

# Set RID file
ENV RTI_RID_FILE=$RTI_HOME/rid.mtl

COPY start.sh /root/rtiexec/
WORKDIR /root/rtiexec

COPY supervisord.conf /etc/supervisor/supervisord.conf
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
