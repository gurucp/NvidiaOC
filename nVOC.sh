#!/bin/bash
##
#Define Environment Variable 
#
MemoryOffset="1600"
ClockOffset="-200"
FanSpeed="80"
export DISPLAY=:0
xset -dpms
xset s off
xhost +

##Create xorg.conf with cool bits. I will use 31.. please check the manual properly 
nvidia-xconfig -a --force-generate --allow-empty-initial-configuration --cool-bits=31 --no-sli --connected-monitor="DFP-0"
echo "In case of any error please reboot and run this script again"

# Paths to the utilities we will need
SMI='/usr/bin/nvidia-smi'
SET='/usr/bin/nvidia-settings'

# Determine major driver version
VER=$(awk '/NVIDIA/ {print $8}' /proc/driver/nvidia/version | cut -d . -f 1)

# Drivers from 285.x.y on allow persistence mode setting
if [ "${VER}" -lt 285 ]
then
    echo "Error: Current driver version is ${VER}. Driver version must be greater than 285."; exit 1;
fi

    $SMI -pm 1 # enable persistance mode
    $SMI -i 0,1,2,3,4 -pl 90

    echo "Applying Settings"

    # how many GPU's are in the system?
    NUMGPU="$(nvidia-smi -L | wc -l)"

    # loop through each GPU and individually set fan speed
    n=0
    while [  $n -lt  "$NUMGPU" ];
    do
        # start an x session, and call nvidia-settings to enable fan control and set speed
        ${SET} -c :0 -a [gpu:${n}]/GPUFanControlState=1 -a [fan:${n}]/GPUTargetFanSpeed=$FanSpeed
        ${SET} -c :0 -a [gpu:${n}]/GpuPowerMizerMode=1
        ${SET} -c :0 -a [gpu:${n}]/GPUMemoryTransferRateOffset[3]=$MemoryOffset
        ${SET} -c :0 -a [gpu:${n}]/GPUGraphicsClockOffset[3]=$ClockOffset
        let n=n+1
    done

    echo "Complete"; exit 0;

