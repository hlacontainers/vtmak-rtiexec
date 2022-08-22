#!/bin/sh

#
# Copyright 2020 Tom van den Berg (TNO, The Netherlands).
# SPDX-License-Identifier: Apache-2.0
#

# This script starts the MAK RTI EXEC

WaitForHostPort() {
	_NAME=$1
	_HOST=$2
	_PORT=$3

	down=1
	while [ $down -ne 0 ]; do
		echo "CRC: Wait for $_NAME at $_HOST:$_PORT"

		# Check if the port is open; use the -z option to just scan and not connect
		down=`nc -z $_HOST $_PORT < /dev/null > /dev/null; echo $?`

		# Sleep for the next attempt
		sleep 1
	done
	echo "CRC: $_NAME $_HOST:$_PORT is up"
}

WaitForXServer() {
	#split address
	_OLDIFS=$IFS
	IFS=:
	set -- $1
	XHOST=$1
	XDISPLAY_SCREEN=$2
	IFS=.
	set -- $XDISPLAY_SCREEN
	XDISPLAY=$1
	XSCREEN=$2
	IFS=$_OLDIFS

	if [ "$XHOST" = "" ]; then
		echo "CRC: no host or display set in '$DISPLAY' (ignored)"
		return
	fi
	
	if [ "$XDISPLAY" = "" ]; then
		echo "CRC: DISPLAY number is not set, assume 0"
		XDISPLAY=0
	fi
	
	#Update display
	DISPLAY=${XHOST}:${XDISPLAY}

	XPORT=`expr $XDISPLAY + 6000`
		
	WaitForHostPort "XServer" $XHOST $XPORT
}

# Set defaults
X=${MAK_RTI_CONFIGURE_CONNECTION_WITH_RID:=1}
X=${MAK_RTI_USE_RTI_EXEC:=1}
X=${MAK_RTI_FOM_DATA_TRANSPORT_TYPE_CONTROL:=2}
X=${MAK_RTI_MOM_SERVICE_AVAILABLE:=1}
X=${MAK_RTI_THROW_EXCEPTION_CALL_NOT_ALLOWED_FROM_WITHIN_CALLBACK:=1}
X=${MAK_RTI_CHECK_FLAG:=1}
X=${MAK_RTI_ENABLE_HLA_OBJECT_NAME_PREFIX:=1}
X=${MAK_RTI_STRICT_FOM_CHECKING:=1}
X=${MAK_RTI_STRICT_NAME_RESERVATION:=1}
X=${MAK_RTI_RTIEXEC_PERFORMS_LICENSING:=1}
X=${MAK_RTI_USE_32BITS_FOR_VALUE_SIZE:=1}

if [ -n "$MAK_RTI_RID_FILE" ]; then
	RTI_RID_FILE=$MAK_RTI_RID_FILE
fi

export RTI_RID_FILE

my_address=$(hostname -i)

# Configure the forwarder to listen on its own address
echo "Setting RTI_tcpForwarderAddr to $my_address"
sed -i "s/(setqb RTI_tcpForwarderAddr.*/(setqb RTI_tcpForwarderAddr \"$my_address\")/" $RTI_RID_FILE

# Also set the network interfaces (same as -i an -N options)
echo "Setting RTI_networkInterfaceAddr to $my_address"
sed -i "s/(setqb RTI_networkInterfaceAddr.*/(setqb RTI_networkInterfaceAddr \"$my_address\")/" $RTI_RID_FILE
echo "Setting RTI_tcpNetworkInterfaceAddr to $my_address"
sed -i "s/(setqb RTI_tcpNetworkInterfaceAddr.*/(setqb RTI_tcpNetworkInterfaceAddr \"$my_address\")/" $RTI_RID_FILE

# Set the others
if [ -n "$MAK_RTI_CONFIGURE_CONNECTION_WITH_RID" ]; then
	sed -i "s/(setqb RTI_configureConnectionWithRid.*/(setqb RTI_configureConnectionWithRid $MAK_RTI_CONFIGURE_CONNECTION_WITH_RID)/" $RTI_RID_FILE
fi

if [ -n "$MAK_RTI_USE_RTI_EXEC" ]; then
	sed -i "s/(setqb RTI_useRtiExec.*/(setqb RTI_useRtiExec $MAK_RTI_USE_RTI_EXEC)/" $RTI_RID_FILE
fi

if [ -n "$MAK_RTI_FOM_DATA_TRANSPORT_TYPE_CONTROL" ]; then
	sed -i "s/(setqb RTI_fomDataTransportTypeControl.*/(setqb RTI_fomDataTransportTypeControl $MAK_RTI_FOM_DATA_TRANSPORT_TYPE_CONTROL)/" $RTI_RID_FILE
fi

if [ -n "$MAK_RTI_MOM_SERVICE_AVAILABLE" ]; then
	sed -i "s/(setqb RTI_momServiceAvailable.*/(setqb RTI_momServiceAvailable $MAK_RTI_MOM_SERVICE_AVAILABLE)/" $RTI_RID_FILE
fi

if [ -n "$MAK_RTI_THROW_EXCEPTION_CALL_NOT_ALLOWED_FROM_WITHIN_CALLBACK" ]; then
	sed -i "s/(setqb RTI_throwExceptionCallNotAllowedFromWithinCallback.*/(setqb RTI_throwExceptionCallNotAllowedFromWithinCallback $MAK_RTI_THROW_EXCEPTION_CALL_NOT_ALLOWED_FROM_WITHIN_CALLBACK)/" $RTI_RID_FILE
fi

if [ -n "$MAK_RTI_CHECK_FLAG" ]; then
	sed -i "s/(setqb RTI_checkFlag.*/(setqb RTI_checkFlag $MAK_RTI_CHECK_FLAG)/" $RTI_RID_FILE
fi

if [ -n "$MAK_RTI_ENABLE_HLA_OBJECT_NAME_PREFIX" ]; then
	sed -i "s/(setqb RTI_enableHlaObjectNamePrefix.*/(setqb RTI_enableHlaObjectNamePrefix $MAK_RTI_ENABLE_HLA_OBJECT_NAME_PREFIX)/" $RTI_RID_FILE
fi

if [ -n "$MAK_RTI_STRICT_FOM_CHECKING" ]; then
	sed -i "s/(setqb RTI_strictFomChecking.*/(setqb RTI_strictFomChecking $MAK_RTI_STRICT_FOM_CHECKING)/" $RTI_RID_FILE
fi

if [ -n "$MAK_RTI_STRICT_NAME_RESERVATION" ]; then
	sed -i "s/(setqb RTI_strictNameReservation.*/(setqb RTI_strictNameReservation $MAK_RTI_STRICT_NAME_RESERVATION)/" $RTI_RID_FILE
fi

if [ -n "$MAK_RTI_RTIEXEC_PERFORMS_LICENSING" ]; then
	sed -i "s/(setqb RTI_rtiExecPerformsLicensing.*/(setqb RTI_rtiExecPerformsLicensing $MAK_RTI_RTIEXEC_PERFORMS_LICENSING)/" $RTI_RID_FILE
fi

if [ -n "$MAK_RTI_USE_32BITS_FOR_VALUE_SIZE" ]; then
	sed -i "s/(setqb RTI_use32BitsForValueSize.*/(setqb RTI_use32BitsForValueSize $MAK_RTI_USE_32BITS_FOR_VALUE_SIZE)/" $RTI_RID_FILE
fi

if [ -n "$MAK_RTI_NOTIFY_LEVEL" ]; then
	sed -i "s/.*(setqb RTI_notifyLevel.*/(setqb RTI_notifyLevel $MAK_RTI_NOTIFY_LEVEL)/" $RTI_RID_FILE
fi

if [ -n "$MAK_RTI_LOG_FILE_DIRECTORY" ]; then
	sed -i "s:.*(setqb RTI_logFileDirectory .*):(setqb RTI_logFileDirectory \"$MAK_RTI_LOG_FILE_DIRECTORY\"):" $RTI_RID_FILE
fi

if [ -n "$MAK_RTI_RTIEXEC_LOG_FILE_NAME" ]; then
	sed -i "s:.*(setqb RTI_rtiExecLogFileName.*):(setqb RTI_rtiExecLogFileName \"$MAK_RTI_RTIEXEC_LOG_FILE_NAME\"):" $RTI_RID_FILE
fi

if [ -n "$DISPLAY" ]; then
	WaitForXServer $DISPLAY
fi

echo "CRC: start"

# Start process
cd $RTI_HOME/bin
./rtiexec $@
