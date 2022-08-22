#
# Copyright 2020 Tom van den Berg (TNO, The Netherlands).
# SPDX-License-Identifier: Apache-2.0
#

# Set default for build-time ARGs
ARG VTMAK_VERSION=skeleton

#####################
# Create base image #
#####################
# CentOS on DockerHub is basically end of lifed since Dec 2021. RedHat switched to quay for hosting images,
# and rebranded the product to CentOS Stream. An alternative is Rocky Linux.
FROM quay.io/centos/centos:stream8 

ARG VTMAK_VERSION

# Mesa is an open source software implementation of OpenGL, Vulkan, and other graphics API specifications.
# Mesa translates these specifications to vendor-specific graphics hardware drivers.
# The following Mesa packages are installed:
# * mesa-libGLU: Mesa implementation of the standard GLU OpenGL utility API.
# * mesa-libEGL: Mesa libEGL runtime libraries.
# * mesa-dri-drivers: Mesa-based Direct Rendering Infrastructure (DRI) drivers.
# * mesa-filesystem: Mesa driver filesystem.
# * mesa-libGLES: Mesa libGLES runtime libraries (3rd party)
# * mesa-libGLw: Xt / Motif OpenGL widgets
# * mesa-libOSMesa: Mesa offscreen rendering libraries

# Also install X Server utilities with the X11 libs that we need:
# * xorg-x11-server-utils: utilities and associated X11 libs.

# In addition, the MaK RTI Exec requires several packages for fonts and keyboard:
# * fontconfig: Font configuration and customization library
# * libicu: Unicode services on a wide variety of platforms.
# * libpng: Library of functions for manipulating PNG image format files
# * libtiff: Library of functions for manipulating TIFF image format files
# * libxkbcommon: X.Org library for compiling XKB maps into formats usable by the X Server.
# * xkeyboard-config: X Keyboard Extension configuration data.

RUN yum install -y \
	xorg-x11-server-utils \
	mesa-libGLU mesa-libEGL mesa-dri-drivers mesa-filesystem mesa-libGLES mesa-libGLw mesa-libOSMesa \
	fontconfig \
	libicu \
	libpng libtiff \
	libxkbcommon \
	&& \
	rm -rf /var/cache/yum/*

# On stream we need to install these for ps and hostname.
RUN yum install -y procps hostname && rm -rf /var/cache/yum/*
	
# Install supervisor as lool to manage the RTI Exec, along with some
# networking tools for trouble shooting if needed. Use the epel-release
# to get supervisor:
RUN yum install -y epel-release
RUN yum install -y supervisor nc iproute nmap && rm -rf /var/cache/yum/*

# The MaK RTI files are installed here
ENV RTI_HOME=/usr/local/makRti${VTMAK_VERSION}

# Ensure there is a skeleton structure that can be used by derived images if the MaK installer file is empty
RUN mkdir -p ${RTI_HOME}/bin ${RTI_HOME}/lib ${RTI_HOME}/data ${RTI_HOME}/include
RUN touch ${RTI_HOME}/rid.mtl

# Install Mak RTI; nothing will happen if the MaK installer file is empty
ADD ./makRti${VTMAK_VERSION}-linux64-rhe8*.tar.gz /usr/local

# Set library path in case we want to start the rtiexec from the assistant
ENV LD_LIBRARY_PATH=${RTI_HOME}/lib:${RTI_HOME}/lib/gui

# Set RID file
ENV RTI_RID_FILE=$RTI_HOME/rid.mtl

COPY start.sh /root/rtiexec/
WORKDIR /root/rtiexec

COPY supervisord.conf /etc/supervisor/supervisord.conf
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
