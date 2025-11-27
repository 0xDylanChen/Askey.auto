#!/bin/bash

# pack useful debugging information to USB disk

HW_VER=""
APP_INFO_LOCATION=""
USB_DISK_LOCATION=""
LOG_LOCATION=""

 

function check_hw_ver()
{
    HW_VER=`fw_printenv HW_VER | cut -d "=" -f2`

    echo "Board HW_VER is: $HW_VER"
    if [[ "$HW_VER" == "ES3" ]]; then
        APP_INFO_LOCATION="/run/media/sda4/"
        USB_DISK_LOCATION="/run/media/sda4/"
    elif [[ "$HW_VER" == "EV1" ]]; then
        APP_INFO_LOCATION="/run/media/mmcblk0p4/"
        USB_DISK_LOCATION="/home/root/"
    else
        echo "unsupported HW_VER"
        exit
    fi

    echo "app dbg info location: $APP_INFO_LOCATION"
    echo "usb disk location: $USB_DISK_LOCATION"
}

function pack_to_usb_disk()
{
    LOG_LOCATION=`mktemp -d $USB_DISK_LOCATION"obu_debug.XXXXXXXXXX"`

    if [[ $LOG_LOCATION == *$USB_DISK_LOCATION* ]]; then
        echo "packing useful debugging information to USB disk ... ..."
        mkdir $LOG_LOCATION"/app"
        cp -r $APP_INFO_LOCATION"conf/" $LOG_LOCATION"/app"
        cp $APP_INFO_LOCATION"cohda."* $LOG_LOCATION"/app" 2>/dev/null
        cp $APP_INFO_LOCATION*".db"* $LOG_LOCATION"/app"
        cp $APP_INFO_LOCATION"runlog."* $LOG_LOCATION"/app"
        cp $APP_INFO_LOCATION"saebsm.log."* $LOG_LOCATION"/app" 2>/dev/null
        cp $APP_INFO_LOCATION"tcu_gnss_nmea.log."* $LOG_LOCATION"/app"
        cp /usr/bin/tcu_main $LOG_LOCATION"/app"
        cp -r /var/volatile/log $LOG_LOCATION"/var_log"
        cp /var/volatile/core_* $LOG_LOCATION 2>/dev/null
        cp /proc/sw_version $LOG_LOCATION
        cp /etc/build $LOG_LOCATION
        echo "$HW_VER" > $LOG_LOCATION"/HW_VER"
        journalctl -u tcu_app > $LOG_LOCATION"/journalctl_tcu_app.txt"
        sync
        echo "Done. obu debug info has been pack to $LOG_LOCATION"
    else
        echo "Failed to create temp folder $LOG_LOCATION --  $USB_DISK_LOCATION"
        exit
    fi
}

#function umount_disk()
#{
#    umount $USB_DISK_LOCATION
#    echo "Now you can unplug your disk"
#}

#check_hw_ver
#pack_to_usb_disk
#umount_disk