#Smoke test / long term 
#ver ALPS
!/bin/bash


#fist value
arg1="$1"

#result
tmp_HW="/tmp/HWresult"
tmp_SW="/tmp/SWresult"
tmp_end="/home/root/result"

#tmp
tmp_1="/tmp/tmp1.txt"
tmp_2="/tmp/tmp2.txt"
tmp_="/tmp/tmp.txt"

#pc side setting 
eth0="192.168.19.196"
eth0_v6="fd53:7cd8:383:15::200"
eth1="10.0.0.2"
eth1_v6="fd53:7cb8:383:17::190"

wlan0="192.168.1.2"
wlan1="192.168.2.2"
#wlan0="192.168.50.2"
#wlan1="192.168.51.2"

#ping WWAN 
ipv4_="8.8.8.8"
ipv6_="2001:4860:4860::8888"
dns_="dns.google "

#wifi name
wlan0_name="ctx0800_SIT_2G"
wlan1_name="ctx0800_SIT_5G"

#wifi path
host_apd_path_2g="/etc/hostapd_ctx0800.conf"
host_apd_path_5g="/etc/hostapd_ctx0800_5g.conf"

#LAB PC mac
windows_NB_mac="38:d5:47:8c:ce:fc"
linux_PC_mac="16:49:68:64:66:bb"

#display disable 
null_display="> /dev/null"
# 2> is error meg
# 2>&1 both 


#script functions
log_all(){
	echo "TEST_SetLogModuleLevel FWUpdateM info" >/opt/sfifo 
	echo "TEST_SetLogModuleLevel test info" >/opt/sfifo 
	echo "TEST_SetLogModuleLevel GpsM info" >/opt/sfifo
	echo "TEST_SetLogModuleLevel 5GM info" >/opt/sfifo 
	echo "TEST_SetLogModuleLevel MCUM info" >/opt/sfifo
	echo "TEST_SetLogModuleLevel PowerH info" >/opt/sfifo
	echo "TEST_SetLogModuleLevel EthernetM info" >/opt/sfifo
	echo "TEST_SetLogModuleLevel SmsH info" >/opt/sfifo
	echo "TEST_SetLogModuleLevel DataM info" >/opt/sfifo
	echo "TEST_SetLogModuleLevel MqttM info" >/opt/sfifo
	echo "TEST_SetLogModuleLevel V2XM info" >/opt/sfifo
	echo "TEST_SetLogModuleLevel MobileyeM info" >/opt/sfifo
	echo "TEST_SetLogModuleLevel QcGnssM info" >/opt/sfifo
	echo "TEST_SetLogModuleLevel WakeupM info" >/opt/sfifo
	echo "TEST_SetLogModuleLevel ecall info" >/opt/sfifo
}


function audio_bring_up(){
echo "Enable Audio"
	#echo 12 > /sys/class/i2c-dev/i2c-3/device/3-0060/carModel
	#echo 1 > /sys/class/i2c-dev/i2c-3/device/3-0060/init
	#echo 0 > /sys/class/i2c-dev/i2c-3/device/3-0060/vol
	#echo 0 > /sys/class/i2c-dev/i2c-3/device/3-0060/mute
	#echo 0 > /sys/class/i2c-dev/i2c-3/device/3-006c/mute
	#echo 1 > /sys/class/i2c-dev/i2c-3/device/3-006c/pwr_amp_ctl
	#echo 0x2300 0x1 > /sys/class/i2c-dev/i2c-3/device/3-0060/writeDspMem
	#sleep 50
	#echo -e "4\n1\n1\n16000\n3\n2\n1\n257\n9\n" | audio_console_app > /dev/null &
	clear
	
	#pt_audio
}

function mqtt_speed(){

echo "mqtt CAR speed send"
mosquitto_pub -u admin -P admin -h localhost -t '/vehicle/info' -m '{"speed":198.7,"transmission":1,"timestamp":123456}'	

}

function BT_enable(){
echo "Enalbe BT"
nfore_ble_test &
}

function WIFI_enable(){
echo "Enalbe wifi"
hostapd_run 
}

function ami_Check(){
	#AMI
	echo "AMI " >> ${tmp_end}
	AmiClient_demo | grep fwver >> ${tmp_end}
}

function internet_check(){
echo "Network"
echo "Ipv4/6/DNS ICMP check"
	ping -I usb0.10 -c 1 ${ipv4_}
	if [ $? == "0" ]; then
			sim1_ipv4="1"	
	else 
		echo "usb0.10 ipv4 Ping : false" >> ${tmp_end}
			sim1_ipv4="0"
	fi
		
	ping6 -I usb0.10 -c 2 ${ipv6_} 
	if [ $? == "0" ]; then
			sim1_ipv6="1"
	else 
		echo "usb0.10 ipv6 Ping : false " >> ${tmp_end} 
		sim1_ipv6="0"
	fi

	ping -I usb0.10 -c 2 ${dns_}
	if [ $? == "0" ]; then
		sim1_DNS="1"
	else 
		echo "usb0.10 DNS Ping : false " >> ${tmp_end} 
		sim1_DNS="0"
	fi	
		
	sleep 1
		
	ping -I usb0.20 -c 1 ${ipv4_}
	if [ $? == "0" ]; then
		sim2_ipv4="1"
	else 
		echo "usb0.20 ipv4 Ping : false " >> ${tmp_end} 
		sim2_ipv4="0"
	fi

	ping6 -I usb0.20 -c 2 ${ipv6_}
	if [ $? == "0" ]; then
		sim2_ipv6="1"
	else 
		echo "usb0.20 ipv6 Ping : false " >> ${tmp_end} 
		sim2_ipv6="0"
	fi

	ping -I usb0.20 -c 2 ${dns_}
	if [ $? == "0" ]; then
		sim2_DNS="1"
	else 
		echo "usb0.20 DNS Ping false " >> ${tmp_end}
		sim2_DNS="0"
	fi
		
		
	if [ $sim1_ipv4 = "1" ] && [ $sim1_ipv6 = "1" ] && [ $sim1_DNS = "1" ]; then
		echo "SIM1 : true" >> ${tmp_end}
	else
		echo "SIM1 : false" >> ${tmp_end}
	fi
		
	if [ $sim2_ipv4 = "1" ] && [ $sim2_ipv6 = "1" ] && [ $sim2_DNS = "1" ]; then
		echo "SIM2 : true" >> ${tmp_end}
	else
		echo "SIM2 : false" >> ${tmp_end}
	fi
	sleep 1				
	clear
}

function ethernet_check(){
	ping -c 1 ${eth0}
	if [ $? == "0" ]; then
		echo "eth0 : true " >> ${tmp_end}
	else 
		echo "eth0 : false " >> ${tmp_end}			
	fi
		
	ping -c 1 ${eth1}
	if [ $? == "0" ]; then
		echo "eth1 : true " >> ${tmp_end}
	else 
		echo "eth1 : false " >> ${tmp_end}			
	fi
	
		ping -c 1 ${eth0_v6}
	if [ $? == "0" ]; then
		echo "eth0_v6 : true " >> ${tmp_end}
	else 
		echo "eth0_v6 : false " >> ${tmp_end}			
	fi
		
	ping -c 1 ${eth1_v6}
	if [ $? == "0" ]; then
		echo "eth1_v6 : true " >> ${tmp_end}
	else 
		echo "eth1_v6 : false " >> ${tmp_end}			
	fi
}

function WIFI_check(){		
ping -c 1 ${wlan0}
	if [ $? == "0" ]; then
		echo "wlan0 : true " >> ${tmp_end}
	else 
		echo "wlan0 : false " >> ${tmp_end}			
	fi
		
	ping -c 1 ${wlan1}
	if [ $? == "0" ]; then
		echo "wlan1 : true " >> ${tmp_end}
	else 
		echo "wlan1 : false " >> ${tmp_end}			
	fi
	echo "===============================================" >> ${tmp_end}	

}

function obu_status_mqtt(){
	mosquitto_sub -h 127.0.0.1 -p 1883 -u admin -P admin -t "TextNotification/OBUStatus/v1/All/v1" >> ${tmp_1} &
	killall mosquitto_sub
		
	echo " ===================================================================" >> ${tmp_end}			
	cat ${tmp_1} | awk 'BEGIN{RS=","}{print $1}' | grep -i imei >> ${tmp_end}
	cat ${tmp_1} | awk 'BEGIN{RS="}"}{print $1}' | awk 'BEGIN{RS=","}{print $1}' | grep -i gnss >> ${tmp_end}			
	cat ${tmp_1} | awk 'BEGIN{RS="}"}{print $1}' | awk 'BEGIN{RS=","}{print $1}' | grep -i imu >> ${tmp_end}			
	cat ${tmp_1} | awk 'BEGIN{RS="}"}{print $1}' | awk 'BEGIN{RS=","}{print $1}' | grep  wifi >> ${tmp_end}			
	cat ${tmp_1} | awk 'BEGIN{RS="}"}{print $1}' | awk 'BEGIN{RS=","}{print $1}' | grep -1 can | grep -v temp >> ${tmp_end}			
	cat ${tmp_1} | awk 'BEGIN{RS="}"}{print $1}' | awk 'BEGIN{RS=","}{print $1}' | grep ble | grep "{" | grep -v wifi	>> ${tmp_end}				
	echo " ===================================================================" >> ${tmp_end}			
	rm -r ${tmp_1}
	sleep 1
	killall mosquitto_sub
	
}

function gps_check(){
	echo " **GPS function test"
	chronyc sources -v
	sleep 1 
	gpspipe -r | grep RMC &
	sleep 1
	killall gpspipe -r

	echo " =====================MQTT v2x/gnss======================================="
	mosquitto_sub -h 127.0.0.1 -p 1883 -u admin -P admin -t "/v2x/gnss" &
	sleep 1
	killall mosquitto_sub
	echo " ==================================================================="
		
	sleep 1
	
}

function acme_check(){

	echo " **Check CV2X status"
	kinematics-sample-client -a -n 1 | grep -E "lat|long"
	echo " ==================================================================="
	echo " ==================================================================="
	cv2x-config --get-v2x-status | grep V2X
	echo " ==================================================================="
	sleep 1
		
	echo "acme TX/RX"
	acme &
	sleep 1
	acme -R &	
	
	sleep 5
	killall acme

	clear
}

function store_space_check(){
#dmesg | grep -i FAILED >> HWrerult
	echo " **OTG/eMMC space"
	df -h 
	echo " ===================================================================" >> result
}

function time_check(){

echo "time_check" >> ${tmp_end}
date -R >> ${tmp_end}
sleep 1

}

function result_show(){
cat ${tmp_HW} >> ${tmp_end}
cat ${tmp_SW} >> ${tmp_end}
sleep 1	
cat ${tmp_end}
}

function result_del(){
rm -r ${tmp_end}
}

function sim_information(){

echo -e "1\n15\n1\n4\n0\n0\n" | telsdk_console_app | grep -i3 iccid
sleep 1
echo -e "1\n15\n2\n4\n0\n0\n" | telsdk_console_app | grep -i3 iccid

}


#basic function script 
function Setup(){
	clear
    echo "Setup env"
    killall nfore_ble_test
	
	systemctl enable sshd.socket
	systemctl start sshd.socket
	
	sed -i "s/CTX0800/${wlan0_name}/g" ${host_apd_path_2g}
	sed -i "s/CTX0800_5G/${wlan1_name}/g" ${host_apd_path_5g}
	
	log_all
}

function hw_Check(){
    clear
	rm -r ${tmp_HW}
	echo "HW check"
	CHECKSPI=`dmesg | grep -Fo "fsl-flexspi 5d120000.flexspi: mt35xu256aba (32768 Kbytes)"`
	if [ "$CHECKSPI" = "fsl-flexspi 5d120000.flexspi: mt35xu256aba (32768 Kbytes)" ]; then
		echo "Kernel SPI NOR : true " >> ${tmp_HW} 
	else 
		echo " Kernel SPI NOR : false " >> ${tmp_HW}
	fi

	EV1=`fw_printenv HW_VER`
	if [ "$EV1" = "HW_VER=EV1" ]; then
		echo "HW_Version : true " >> ${tmp_HW} 	
	else 
		echo "HW_Version : false  " >> ${tmp_HW} 
	fi

 
	echo "  {fdisk -l (get mtblock0 ~ mtdblock2 data)" >> ${tmp_HW}
	fdisk -l  > tmp.txt 
	cat tmp.txt | grep -i "/dev/mmcblk0p1" >> ${tmp_HW}
	cat tmp.txt | grep -i "/dev/mmcblk0p2" >> ${tmp_HW} 
	cat tmp.txt | grep -i "/dev/mmcblk0p3" >> ${tmp_HW}
	cat tmp.txt | grep -i "/dev/mmcblk0p4" >> ${tmp_HW}
	rm -r tmp.txt
	

	echo " DDR4/DRAM 1.7G"
	DRAM=`free -h | grep -o 1.7G`
	if [ "$DRAM" = "1.7G" ]; then
		echo "DRAM : true " >> ${tmp_HW}
	else 
		echo " DRAM : false  " >> ${tmp_HW}
	fi
	
	echo " **HSM"
	touch ${tmp_}
	touch ${tmp_2}
	/usr/bin/sxf1800/v2xse-se-info  > ${tmp_}
	cat ${tmp_} | grep -i "Utility ver" > ${tmp_2}
	cat ${tmp_2}

	HSM=`cat ${tmp_2}`
	if [ "$HSM" = "Utility version is: 2.1.2" ]; then
		echo "HSM : true " >> ${tmp_HW}
	else 
		echo "HSM : false " >> ${tmp_HW}
	fi
	rm -r ${tmp_}
	rm -r ${tmp_2}


}

function sw_Check(){

	rm -r ${tmp_SW}
	
	clear
    #####################
	echo "SW check"
	sleep 1	
	#echo "SW_Version " >> ${tmp_SW}
	#cat /proc/sw_version >> ${tmp_SW}
	#echo "OBU build "
	#cat /etc/build 
	pt_diagnostics
	
	pt_diagnostics >> ${tmp_1}
	
	cat ${tmp_1} | grep -i soc_fw_ver >> ${tmp_SW}
	cat ${tmp_1} | grep -i mcu_fw_ver >> ${tmp_SW}
	cat ${tmp_1} | grep -i alps_sdk_ver >> ${tmp_SW}
	cat ${tmp_1} | grep -i alps_fw_ver >> ${tmp_SW}
	
	rm -r ${tmp_1}
	
	#echo "OBU SDK Version " >> ${tmp_SW}
	#cat /etc/alap_version | grep Version >> ${tmp_SW}

	#echo "MCU APP_VER " >> ${tmp_SW}
	#echo "TEST_START" > /opt/sfifo
	#tail -f /run/media/mmcblk0p4/runlog.txt | grep "MCU ver" & >> ${tmp_}
	#echo "TEST_MCU get_mcu_ver" > /opt/sfifo && sleep 3
	#cat ${tmp_} >> ${tmp_SW}
	#killall tail 
	#echo "TEST_STOP" > /opt/sfifo
	#rm -r ${tmp_}
	
	#echo "================================================"
	#echo "ALPS Ver = " >> ${tmp_SW}
	#adb shell cat /firmware/image/Ver_Info.txt | grep -i 5AB >> ${tmp_SW}

#####################
	echo " ===================================================================" >> ${tmp_SW}
	
	clear
}

function func_check(){

    echo "Test Scripe " >> ${tmp_end}
	echo "Function check"	
	
	#set -e

	#BT_enable 
	
	#WIFI_enable 
		
	mqtt_speed	
	
	audio_bring_up
	
	echo "check ami"
	ami_Check

	while true : 
	do 		
		result_del							
		
		#SIM Check
		#telsdk fail "TBD bug"		
		#sim_information 
		
		#sim1 sim2 
		internet_check
		
		#ETH 10.0.0.2/192.168.19.196
		ethernet_check
		
		#192.168.1.2/192.168.2.2
		#WIFI_check
		
		obu_status_mqtt
						
		gps_check
		
		acme_check
		
		time_check
				
		result_show		
		
		sleep 10
		
		if [ "$arg1" = "reboot" ]; then
			echo " received reboot arg system reboot "
			reboot
		else 
			store_space_check
		fi
	done	
}


function rm_config(){

echo "remove log"
rm -r /run/media/mmcblk0p4/runlog*

}


LOG_DIR="/run/media/mmcblk0p4/OBU_longterm_test"
COMPRESSED_DIR="${LOG_DIR}/compressed"
CHECK_INTERVAL=86400  

function longterm_setup(){
ls -l ${LOG_DIR}
rm -r ${LOG_DIR}/*
sync

mkdir ${LOG_DIR}

gpspipe -r -t -c -n 100 >>  ${LOG_DIR}/Gpspipe.txt &

LOG_DIR="/run/media/mmcblk0p4/OBU_longterm_test"

# Define common ping and iperf commands
ping_cmd="ping -I $1 $2 -c $CHECK_INTERVAL | awk '{ print strftime(\"%Y-%m-%d %H:%M:%S\" , systime()) $0}'"
iperf_cmd="iperf3 -c $1 -p $2 --forceflush -t $CHECK_INTERVAL -R | awk '{ print strftime(\"%Y-%m-%d %H:%M:%S\" , systime()) $0}'"

# Run commands in the background
gpspipe -r -t -c -n 100 >> "${LOG_DIR}/Gpspipe.txt" &

# Ping commands
$ping_cmd usb0.10 ${ipv4_} >> "${LOG_DIR}/sim1Ipv4.txt" &
$ping_cmd usb0.20 ${ipv4_} >> "${LOG_DIR}/sim2Ipv4.txt" &
$ping_cmd eth0 >> "${LOG_DIR}/ping_eth0.txt" &
$ping_cmd eth1 >> "${LOG_DIR}/ping_eth1.txt" &

# Iperf  commands
$iperf_cmd eth0 5202 >> "${LOG_DIR}/iperf3_5202_eth0.txt" &
$iperf_cmd eth1 5203 >> "${LOG_DIR}/iperf3_5203_eth1.txt" &
$iperf_cmd wlan0 5204 >> "${LOG_DIR}/iperf3_5204_wifi24.txt" &
$iperf_cmd wlan1 5205 >> "${LOG_DIR}/iperf3_5205_wifi5G.txt" &

}

function longterm_run(){

#5day
testTime=433000 

MULTIPLIER=10
sum_time=0

#first run 
longterm_setup

while [[ $sum_time -lt $testtime ]]; do
	
	echo ""
	((i++))
	
    sum_time=$((i * $MULTIPLIER})
    echo "The long-term test has been running for $sum_time seconds"
	
	echo ""
	tail -1 ${LOG_DIR}/ping_eth0.txt
	tail -1 ${LOG_DIR}/ping_eth1.txt
	tail -1 ${LOG_DIR}/sim1Ipv4.txt
	tail -1 ${LOG_DIR}/sim2Ipv4.txt
	tail -1 ${LOG_DIR}/Gpspipe.txt
	echo ""
	echo "iperf 5202 = eth0 , 5203 = eth1 , 5204 = wifi2.4G, 5205=wifi5G"
	tail -1 ${LOG_DIR}/iperf3_5202_eth0.txt
	tail -1 ${LOG_DIR}/iperf3_5203_eth1.txt
	tail -1 ${LOG_DIR}/iperf3_5204_wifi24.txt
	tail -1 ${LOG_DIR}/iperf3_5205_wifi5G.txt
	
	if [$sum_time % $CHECK_INTERVAL -eq 0]; then 
		compress_logs
		longterm_setup
	fi 

	sleep $MULTIPLIER
    done
	
}

function compress_logs(){

    yesterday=$(date -d yesterday +%Y-%m-%d)

   
    log_files=$(find "$LOG_DIR" -name "*.txt" -mtime +0 -mtime -1)

   
    if [ -n "$log_files" ]; then
       
        tar_file="${COMPRESSED_DIR}/${yesterday}.tar.gz"

      
        mkdir -p "$COMPRESSED_DIR"

       
        tar czvf "$tar_file" $log_files

      
        rm -f $log_files
    fi
}

function suspend_enter(){

echo "TEST_CANNM_START" > /opt/sfifo

}

#QDR Seed
rolloffset="$2"
yawoffset="$3"
pitchoffset="$4"
offsetUnc="$5"
speedfactor="$6"
speedfactorUnc="$7"
gyrofactor="$8"
gyrifactorUnc="$9"

function QDR_seed_input(){

#QDR seed_input
echo " rolloffset = ${rolloffset} , yawoffset = ${yawoffset} , pitchoffset = ${pitchoffset} offsetUnc = ${offsetUnc} ,
speedfactor = ${speedfactor} speedfactorUnc = ${speedfactorUnc} ,gyrofactor = ${gyrofactor} ,gyrifactorUnc = ${gyrifactorUnc}"

echo -e "24\nY\n$rolloffset\n$yawoffset\n$pitchoffset\n$offsetUnc\ny\n$speedfactor\nY\n$speedfactorUnc\nY\n$gyrofactor\nY\n$gyrifactorUnc\n0" | location_test_app 
sleep 1
#enable QDR engine
echo -e "29\n3\n2\n0\n0" | location_test_app  /dev/null 

}

function QDR_location_app(){


while true : 
do

	i=0 
	echo -e "5\n2\n1\n0\n1\n1000\ny\n0" | location_test_app | grep percent &

	while [ $i -lt 3000 ] ;
	do
		date +"%Y-%m-%d %H:%M:%S.%3N"
		sleep 0.1
		((i++)) 
	done
	#location_confidence_show
	echo "confidence display update"
	killall location_test_app
	sleep 0.5

done



}

#just record 
function set_wol_mac(){

#windows_NB_mac="38:d5:47:8c:ce:fc"

#linux_PC_mac="16:49:68:64:66:bb"

echo "TEST_ETH_WOL_CONFIG ${windows_NB_mac}"  > /opt/sfifo
echo "TEST_ETH_WOL_CONFIG ${linux_PC_mac}"  > /opt/sfifo
echo "TEST_ETH_WOL" > /opt/sfifo

}

#mqtt update .sh
MQTT_HOST='10.0.0.1'
MQTT_PORT=1883
MQTT_JSON="/tmp/TextCommand_Request_OTAFirmwareUpdate.json"

mqtt_publish() {
	TOPIC="$1"
	EPOCH_SEC="$(date +%s)"
    sed -i "s/EPOCH_SEC/${EPOCH_SEC}/g" ${MQTT_JSON}
    checksum=$(cat ${MQTT_JSON}|gzip -1|tail -c 8|head -c 4|hexdump -e '1/4 "%08x"'|tr [:lower:] [:upper:])
    sed -i "s/\"chksum\":0/\"chksum\":\"0x${checksum}\"/g" ${MQTT_JSON}
    mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -u admin -P admin -t "${TOPIC}" -f ${MQTT_JSON}
}

prepare_pub_file() {
    filepath="${arg2}"
    filename="$(basename ${filepath})"
    filehash="$(sha256sum ${filepath} | awk '{print $1}')"
    echo -n '{"header":{"schemaName":"JSON","magic":"","timestamp":{"sec":EPOCH_SEC,"nsec":0},"streamHandler":{"streamID":0,"seqNum":0},"chksum":0},"payloadType":"JSON","payload":{"username":"mobileye","password":"mobileye","firmwareName":"FIRMWARE_NAME","firmwareHash":"FIRMWARE_HASH"}}' > ${MQTT_JSON}
    sed -i "s/FIRMWARE_NAME/${filename}/g" ${MQTT_JSON}
    sed -i "s/FIRMWARE_HASH/${filehash}/g" ${MQTT_JSON}
	mqtt_publish "TextCommand/Request/OTAFirmwareUpdate/v1/All/v1"
}

prepare_pub_start() {
    #adb shell sed -i "s/01386A26/01386A25/g" /firmware/image/Ver_Info.txt
    echo -n '{"header":{"schemaName":"JSON","magic":"","timestamp":{"sec":EPOCH_SEC,"nsec":0},"streamHandler":{"streamID":0,"seqNum":0},"chksum":0},"payloadType":"JSON","payload":{"updateCmd":"start"}}' > ${MQTT_JSON}
    mqtt_publish "TextCommand/Request/OTAFirmwareUpdate/v1/All/v1"
}

prepare_pub_enable() {
    mosquitto_sub -h ${MQTT_HOST} -p ${MQTT_PORT} -u admin -P admin -t 'TextCommand/Response/OTA/v1/Settings/v1' &
    mosquitto_sub -h ${MQTT_HOST} -p ${MQTT_PORT} -u admin -P admin -t 'TextCommand/Response/OTAFirmwareUpdate/v1/All/v1' &
    echo -n '{"header":{"schemaName":"JSON","magic":"","timestamp":{"sec":EPOCH_SEC,"nsec":0},"streamHandler":{"streamID":0,"seqNum":0},"chksum":0},"payloadType":"JSON","payload":{"OTAFirmwareUpdateEnable":true,"localSFTPEnable":true}}' > ${MQTT_JSON}
    mqtt_publish "TextCommand/Request/OTA/v1/Settings/v1"
}

do_upload() {
	curl -v -k --user "mobileye:mobileye" \
	--connect-timeout 10 --max-time 300 \
	-C - -T "${arg2}" "sftp://10.0.0.1:8822/shared/${arg2}"
}

disable_ME_BSM_TXRX(){

sed -i "s/Cohda_P1609RxLogEnableFlag    = 1/Cohda_P1609RxLogEnableFlag    = 0/g" /opt/askey/application/cv2x1609/board.conf 
sed -i "s/Cohda_P1609TxLogEnableFlag    = 1/Cohda_P1609TxLogEnableFlag    = 0/g" /opt/askey/application/cv2x1609/board.conf 
sed -i "s/Cohda_P1609PC5RxLogEnableFlag = 1/Cohda_P1609PC5RxLogEnableFlag = 0/g" /opt/askey/application/cv2x1609/board.conf 
sed -i "s/Cohda_P1609PC5TxLogEnableFlag = 1/Cohda_P1609PC5TxLogEnableFlag = 0/g" /opt/askey/application/cv2x1609/board.conf 
 cat /opt/askey/application/cv2x1609/board.conf


sed -i "s/BSMTx = true/BSMTx = false/g" /opt/askey/application/cv2x1609/obu.cfg
sed -i "s/V2XManagerBSMTx  = true/V2XManagerBSMTx  = false/g" /opt/askey/application/cv2x1609/obu.cfg
sed -i "s/OBERx = true/OBERx = false/g" /opt/askey/application/cv2x1609/obu.cfg

}

enable_ME_BSM_TXRX(){

sed -i "s/Cohda_P1609RxLogEnableFlag    = 0/Cohda_P1609RxLogEnableFlag    = 1/g" /opt/askey/application/cv2x1609/board.conf 
sed -i "s/Cohda_P1609TxLogEnableFlag    = 0/Cohda_P1609TxLogEnableFlag    = 1/g" /opt/askey/application/cv2x1609/board.conf 
sed -i "s/Cohda_P1609PC5RxLogEnableFlag = 0/Cohda_P1609PC5RxLogEnableFlag = 1/g" /opt/askey/application/cv2x1609/board.conf 
sed -i "s/Cohda_P1609PC5TxLogEnableFlag = 0/Cohda_P1609PC5TxLogEnableFlag = 1/g" /opt/askey/application/cv2x1609/board.conf 
 cat /opt/askey/application/cv2x1609/board.conf

sed -i "s/BSMTx = false/BSMTx = true/g" /opt/askey/application/cv2x1609/obu.cfg
sed -i "s/V2XManagerBSMTx  = false/V2XManagerBSMTx  = true/g" /opt/askey/application/cv2x1609/obu.cfg
sed -i "s/OBERx = false/OBERx = true/g" /opt/askey/application/cv2x1609/obu.cfg
cat /opt/askey/application/cv2x1609/obu.cfg
}

v2xCheck_status(){

	kinematics-sample-client -a -n 1 
	cv2x-config --get-v2x-status
	systemctl status cohdacv2x 
	
}


arg2="$2"
arg3="$3"
arg4="$4"
arg5="$5"
arg6="$6"
arg7="$7"
arg8="$8"
arg9="$9"
arg10="$10"
arg11="$11"
arg12="$12"
args="$@"

log_output(){
log_level="info"


for i in ${args}; do
	shift
	set -x

	echo "processing argument  ${i} : ${arg1} ${arg2} ${arg3} ${arg4} ${arg5} ${arg6} ${arg7} ${arg8} ${arg9} ${arg10} ${arg11} ${arg12}" 
	case "$i" in
        "1")
            echo "TEST_SetLogModuleLevel FWUpdateM ${log_level}" > /opt/sfifo
            ;;
        "2")
            echo "TEST_SetLogModuleLevel test ${log_level}" > /opt/sfifo
            ;;
        "3")
            echo "TEST_SetLogModuleLevel GpsM ${log_level}" > /opt/sfifo
            ;;
        "4")
            echo "TEST_SetLogModuleLevel 5GM ${log_level}" > /opt/sfifo
            ;;
        "5")
            echo "TEST_SetLogModuleLevel MCUM ${log_level}" > /opt/sfifo
            ;;
        "6")
            echo "TEST_SetLogModuleLevel PowerH ${log_level}" > /opt/sfifo
            ;;
        "7")
            echo "TEST_SetLogModuleLevel EthernetM ${log_level}" > /opt/sfifo
            ;; 
        "8")
            echo "TEST_SetLogModuleLevel SmsH ${log_level}" > /opt/sfifo
            ;;
        "9")
            echo "TEST_SetLogModuleLevel DataM ${log_level}" > /opt/sfifo
            ;;
        "10")
            echo "TEST_SetLogModuleLevel MqttM ${log_level}" > /opt/sfifo
            ;;
        "11")
            echo "TEST_SetLogModuleLevel V2XM ${log_level}" > /opt/sfifo
            ;;
        "12")
            echo "TEST_SetLogModuleLevel MobileyeM ${log_level}" > /opt/sfifo
            ;;
        "13")
            echo "TEST_SetLogModuleLevel QcGnssM ${log_level}" > /opt/sfifo
            ;;
        "14")
            echo "TEST_SetLogModuleLevel WakeupM ${log_level}" > /opt/sfifo
            ;;
		"15")
            log_all
            ;;
		"log")
			echo "log : "
            ;;
        *)
            log_help
			exit
            ;;
    esac
	set +x

done 


}

log_help(){

echo "1: FWUpdateM
2: test
3: GpsM
4: 5GM
5: MCUM
6: PowerH
7: EthernetM
8: SmsH
9: DataM
10: MqttM
11: V2XM
12: MobileyeM
13: QcGnssM
14: WakeupM"

echo " ./obu_demo.sh log 7 2 6 10 9 ... #max 12 or ./obu_demo.sh log 15 open all log  " 


}


#choice case 
function print_help(){

echo "ex: ./smoke_test.sh basic"

echo "=================act================="
echo "'basic' : function test "
echo "'longterm' : record log to usb "
echo "'runlogrm' : delete runlog "
echo "'suspend' : enter suspend "
echo "'BSMon' or 'BSMoff' : enable/disable BSM function for choda, LOG path '/tmp/log/current/' "
echo "'checkV2X : check v2x'"
echo "'log_help ex: ./obu_demo.sh log -h'"
echo "'QDR_confidence' : check confidence% "
echo "car seed exsample ./obu_demo.sh QDR_seed rolloffset yawoffset pitchoffset offsetUnc speedfactor speedfactorUnc gyrofactor gyrifactorUnc "
#echo "Mountain car seed ./obu_demo.sh QDR_seed 178.982834 -178.629532 5.848804 3.0 1.01799 0.005 1.0 0.005"
echo "sample B car seed ./obu_demo.sh QDR_seed -178.983368 -174.498291 -2.379257 3.0 1.01884 0.005 1.0 0.01"


echo "=================mqtt update =================\n"
echo "./obu_demo enable "
echo "./obu_demo file filename.bz2 "
echo "./obu_demo updload #linux only "
echo "./obu_demo start "



#rolloffset="178.982834"
#yawoffset="-178.629532"
#pitchoffset="5.848804"
#offsetUnc="3.0"
#speedfactor="1.01799"
#speedfactorUnc="0.005"
#gyrofactor="1.0"
#gyrifactorUnc="0.005"
}

#main 
case "${arg1}" in
	"basic")
		Setup
		hw_Check
		sw_Check
		func_check
		;;
	"longterm")
		longterm_run
		;;
	"reboot")
		Setup
		hw_Check
		sw_Check
		func_check
		;;
	"suspend")
		suspend_enter		
		;;
	"runlogrm")
		rm_config	
		;;
	"QDR_seed")
		QDR_seed_input	
		;;
	"QDR_confidence")
		QDR_location_app
		;;
	#mqtt cmd 
	"enable") 
		prepare_pub_enable
		;;
	"file")
		prepare_pub_file
		;;
	"upload")
		do_upload
		;;
	"start")
		prepare_pub_start
		;;
	"BSMon")
		enable_ME_BSM_TXRX
		;;
	"BSMoff")
		disable_ME_BSM_TXRX
		;;
	"checkV2X")
		v2xCheck_status
		;;
	"log")
		log_output
		;;
	#mqtt cmd end
	*)
		print_help
		;;
esac

#nfore_ble_test > /dev/null &
#hostapd_run > /dev/null 
#mkdir /run/media/mmcblk0p4/OBU_longterm_test/V2X
#route -n
#echo "IPV6"
#ping -I usb0.10 ${ipv6_} > /run/media/mmcblk0p4/OBU_longterm_test/sim1Ipv6.txt &
#echo "DNS"
#ping -I usb0.10 ${dns_} > /run/media/mmcblk0p4/OBU_longterm_test/sim1DNS.txt &
#echo "IPV6 "
#ping -I usb0.20 ${ipv6_} > /run/media/mmcblk0p4/OBU_longterm_test/sim2Ipv6.txt &
#echo "DNS"
#ping -I usb0.20 ${dns_} > /run/media/mmcblk0p4/OBU_longterm_test/sim2DNS.txt &
#echo " **GPS function test"
#echo "TEST_QCGNSS NMEALOG_START" > /opt/sfifo
#echo "TEST_GPSD NMEALOG_START" > /opt/sfifo
#tail -f /run/media/mmcblk0p4/tcu_gnss_nmea_QC.log.txt > /run/media/mmcblk0p4/OBU_longterm_test/QC.txt &
#tail -f /run/media/mmcblk0p4/tcu_gnss_nmea_Ublox.log.txt > /run/media/mmcblk0p4/OBU_longterm_test/UBLOX.txt &
#echo " **Check CV2X status"
#tail -f /run/media/mmcblk0p4/cohda.log > /run/media/mmcblk0p4/OBU_longterm_test/V2X/Cohda.log.txt & 
#echo "acme TX"
#acme > /run/media/mmcblk0p4/OBU_longterm_test/V2X/acme.txt & 
#echo "acme RX"
#acme -R > /run/media/mmcblk0p4/OBU_longterm_test/V2X/acme_R.txt & 
#echo "WIFI" 
#ping ${wlan0} > /run/media/mmcblk0p4/OBU_longterm_test/wifi2G.txt &
#ping ${wlan1} > /run/media/mmcblk0p4/OBU_longterm_test/wifi5G.txt &
#echo eth0 /eth1 