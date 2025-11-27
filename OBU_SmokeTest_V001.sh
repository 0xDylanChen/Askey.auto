
tmp_1="/tmp/temp.txt"
tmp_2="CaseResult_newest.txt"
tmp_move="CaseResult_$(date +%Y%m%d).txt"
tmp_="/tmp/Resultviews.txt"


#pc side setting 
eth0="192.168.19.196"
eth0_v6="fd53:7cd8:383:15::200"
eth1="10.0.0.2"
eth1_v6="fd53:7cb8:383:17::190"

wlan0="192.168.1.2"
wlan1="192.168.2.2"
#wlan0="192.168.50.2"
#wlan1="192.168.51.2"

#ping WWlAN 
ipv4_="8.8.8.8"
ipv6_="2001:4860:4860::8888"
dns_="dns.google "

CountTotal=25

prodcutName="CTX0800-D331"
toolver="v001"
testType="Smoke"

Date=$(date +%Y-%m-%d)
version=$(pt_diagnostics | grep -e ver)

function setup(){
	rm tmp_2
	touch tmp_2
	killall tcu_main
	killall nfore_ble_test 
	echo "TEST_SetLogModuleLevel FWUpdateM info" > /opt/sfifo
	
	
	cd /run/media/mmcblk0p4/
	mkdir smoketest_result
	cd smoketest_result
	
	#rm -r /run/media/mmcblk0p4/runlog*
	
	#mv ${tmp_} ${tmp_move}
	echo "" > ${tmp_}
	
	mosquitto_pub -u admin -P admin -h localhost -t 'TextCommand/Request/WWAN/v1/Settings/v1' -m '{"header":{"schemaName":"JSON","magic":"","timestamp":{"sec":1628071772,"nsec":664227000},"streamHandler":{"streamID":0,"seqNum":0},"chksum":"0x1C6B6726"},"payloadType":"JSON","payload":{"5GConnectivity":true,"cellularNetwork":true,"APN":[{"modem0":["internet"]},{"modem1":["internet"]}],"DSDAControl":["modem0","modem1"],"routingControl":[{"sourceInterface":"null","destIP":"185.30.211.154","destInterface":"modem0"},{"sourceInterface":"null","destIP":"61.216.146.85","destInterface":"modem1"}]}}'
	
	
	nfore_ble_test &
	hostapd_run 
	echo "
			Make sure all I/O ports are connected
				Ethernet, Antennas, OTG, SIM cards, Speaker&MIC, BLE, WIFI ...
			
			Press Any Key to Continue...
		 "
	#read -n 1 -s -r
}

function result(){

	echo "**************************************"
	echo "*${prodcutName}, Tool Ver: ${toolver}*"
	echo "*Date: ${Date} 		 			   *"
	echo "*SW version: ${version}			   *"
	echo "*Type: ${testType}			 			   *"
	echo "**************************************"
	echo ""
	echo "PASS Rate [$(grep -oi "PASS" ${tmp_} | wc -l)/$(grep -v '^$' ${tmp_} | wc -l)]"
	
	cat ${tmp_} | grep -i "FAIL"
	echo ""
	
	cat ${tmp_}
}


function version(){

	version = `pt_diagnostics | grep -e ver`
	
	if [ -z "$version" ]; then
		echo "[FAIL]C2467008 Pre-condition check" >> ${tmp_}
	else 
		echo "[PASS]C2467008 Pre-condition check" >> ${tmp_}
		pt_diagnostics | grep -e ver >> ${tmp_1}
	fi
}

function hw_Check(){

	local NTP="chronyd -q 'server 10.0.0.1 iburst'"
	[ -z "$NTP" ]&& \
	echo "[FAIL] C2467011 Verify System Time can sync up with NTP server and same as real time" >> ${tmp_} || \
	echo "[PASS] C2467011 Verify System Time can sync up with NTP server and same as real time" >> ${tmp_}

	echo "TEST_SetLogModuleLevel 5GM debug" > /opt/sfifo
	sleep 3
	log=$(tail -1 /run/media/mmcblk0p4/runlog.txt)
	[ -z "$log" ] && \
	echo "[FAIL] C2467012 Check if log should include DUT status" >> ${tmp_} || \
	echo "[PASS] C2467012 Check if log should include DUT status" >> ${tmp_}
	echo "TEST_SetLogModuleLevel 5GM info" > /opt/sfifo

	CHECKSPI=$(dmesg | grep -Fo "fsl-flexspi 5d120000.flexspi: mt35xu256aba (32768 Kbytes)")
	[ "$CHECKSPI" = "fsl-flexspi 5d120000.flexspi: mt35xu256aba (32768 Kbytes)" ] && \
	echo "[PASS] C2467013 Verify U-Boot & kernel SPI NOR can able to show mt35xu256aba" >> ${tmp_} || \
	echo "[FAIL] C2467013 Verify U-Boot & kernel SPI NOR can able to show mt35xu256aba" >> ${tmp_}

	DRAM=$(free -h | grep -Fo "1.7G")
	[ "$DRAM" = "1.7G" ] && \
	echo "[PASS] C2467014 Verify Kernel storage has 2 GB in DRAM size and free in 1.7GB" >> ${tmp_} || \
	echo "[FAIL] C2467014 Verify Kernel storage has 2 GB in DRAM size and free in 1.7GB" >> ${tmp_}

	eMMC_=$(df -h | grep -Fo "mmcblk0p4" | uniq)
	[ "$eMMC_" = "mmcblk0p4" ] && \
	echo "[PASS] C2467015 Check if it does display eMMC partition of space" >> ${tmp_} || \
	echo "[FAIL] C2467015 Check if it does display eMMC partition of space" >> ${tmp_}

	OTG=$(ls /run/media/ | grep -i sda1)
	[ "$OTG" = "sda1" ] && \
	echo "[PASS] C2467016 Check if it displays the space of USB storage device" >> ${tmp_} || \
	echo "[FAIL] C2467016 Check if it displays the space of USB storage device" >> ${tmp_}

	HSM=$(/usr/bin/sxf1800/v2xse-se-info | grep -Fo Successful)
	[ "$HSM" = "Successful" ] && \
	echo "[PASS] C2467017 Verify the display of HSM(Hardware Security Module) information" >> ${tmp_} || \
	echo "[FAIL] C2467017 Verify the display of HSM(Hardware Security Module) information" >> ${tmp_}

	
	echo "TEST_SetLogModuleLevel test debug" > /opt/sfifo
	echo "TEST_MCU exec_mcu_cmd=10,read sensor temperature" > /opt/sfifo
	sleep 3
	IMU=$(cat /run/media/mmcblk0p4/runlog.txt | grep -Fo "Read_TEMP")
	[ "$IMU" = "Read_TEMP OK" ] && \
	echo "[PASS] C2467018 Verify vector data of sensor from IMU(Inertial Measurement Unit)" >> ${tmp_} || \
	echo "[FAIL] C2467018 Verify vector data of sensor from IMU(Inertial Measurement Unit)" >> ${tmp_}
	
	echo "TEST_SetLogModuleLevel test info" > /opt/sfifo
	sleep 1

}

function internet_check() {

	local ping_cmd="ping -I usb0.10 -c 1"
	local ping6_cmd="ping6 -I usb0.10 -c 2"
	local ping_cmd2="ping -I usb0.20 -c 1"
	local ping6_cmd2="ping6 -I usb0.20 -c 2"
	
	$ping_cmd2 ${ipv4_} && \
	$ping6_cmd2 ${ipv6_} && \
	$ping_cmd2 ${dns_} && \
	$ping_cmd ${ipv4_} && \
	$ping6_cmd ${ipv6_} && \
	$ping_cmd ${dns_} && \
	echo "[PASS] C2467001 [SRS_01250] Check if it does support IPV4/V6 and data transfer normally" >> ${tmp_} || \
	echo "[FAIL] C2467001 [SRS_01250] Check if it does support IPV4/V6 and data transfer normally" >> ${tmp_}

	sleep 1
	
}

function ethernet_check(){
	
	local ping_eth="ping -c 1"
	$ping_eth ${eth0} && \
	$ping_eth ${eth0_v6} && \	
	echo "[PASS] C2466999 Check if data transfer of 1000 base-t ethernet port works normally " >> ${tmp_} || \
	echo "[FAIL] C2466999 Check if data transfer of 1000 base-t ethernet port works normally" >> ${tmp_}
	
	sleep 1

	$ping_eth ${eth1} && \	
	$ping_eth ${eth1_v6} && \
	echo "[PASS] C2467000 Check if data transfer of RJ45 ethernet (Molex) works normally " >> ${tmp_} || \
	echo "[FAIL] C2467000 Check if data transfer of RJ45 ethernet (Molex) works normally " >> ${tmp_}
	
}

function WIFI_check(){		

	local ping_WI="ping -c 1"
	$ping_WI ${wlan0} &&\
	echo "[PASS] C2467003 Verify the connection to WiFi on AP mode (2.4G)  " >> ${tmp_} || \
	echo "[FAIL] C2467003 Verify the connection to WiFi on AP mode (2.4G) " >> ${tmp_}
		
	$ping_WI ${wlan1} &&\
	echo "[PASS] C2467004 Verify the connection to WiFi on AP mode (5G) " >> ${tmp_} || \
	echo "[FAIL] C2467004 Verify the connection to WiFi on AP mode (5G) " >> ${tmp_}
	
	sleep 1

}



function SW(){
	
	gpspipe -w -n 10 | grep -m 1 -o '"lat":[0-9.-]*' > /dev/null && \
	echo "[PASS] C2467002 Verify DUT display GPS 3D fix and current location when GNSS signal is available " >> "${tmp_}" || \
	echo "[FAIL] C2467002 Verify DUT display GPS 3D fix and current location when GNSS signal is available " >> "${tmp_}"
		
	sleep 1
	
	BT=$(dmesg | grep -Fom1 "rfkill: BT RF going to : on")
	[ "$BT" = "rfkill: BT RF going to : on" ] && \
	echo "[PASS] C2467022 [SRS_01140] Verify DUT support Bluetooth v5.0  " >> "${tmp_}" || \
	echo "[FAIL] C2467022 [SRS_01140] Verify DUT support Bluetooth v5.0  " >> "${tmp_}"
		
	sleep 1
	
	v2x=$(dmesg | grep -Fom1 "V2X TX status is active")
	[ "$v2x" = "V2X TX status is active" ] && \
	echo "[PASS] C2467023  Verify the correct transfer data by CV2X" >> "${tmp_}" || \
	echo "[FAIL] C2467023  Verify the correct transfer data by CV2X" >> "${tmp_}"
	
	sleep 1
	
	pt_audio &
	sleep 3

	Audio=$(dmesg | grep -Fom1 "[TAS5411] into Normal")
	[ "$Audio" = "[TAS5411] into Normal" ] && \
	echo "[PASS] C2467024 Verify if audio output normally without noise and echo" >> "${tmp_}" || \
	echo "[FAIL] C2467024 Verify if audio output normally without noise and echo" >> "${tmp_}"	
	
	#killall pt_audio 
	
	sleep 1
}

function CAN(){

	echo "TEST_START" > /opt/sfifo
	sleep 1
	echo "TEST_MCU exec_mcu_cmd=2,CAN0,1234,A1A2A3A4A5A6A7A8" > /opt/sfifo
	echo "TEST_MCU exec_mcu_cmd=2,CAN1,1234,C1C2C3A4A5A6A7A8" > /opt/sfifo
	
	sleep 5 
	
	local CAN1="cat /run/media/mmcblk0p4/runlog.txt | grep -Fo 'A1A2A3A4A5A6A7A8' | uniq"
	[ -z "$CAN1" ] && \
	echo "[FAIL] Verify CAN1 can be connected to MCU via echo command " >> "${tmp_}" || \
	echo "[PASS] Verify CAN1 can be connected to MCU via echo command " >> "${tmp_}"
	
	local CAN2="cat /run/media/mmcblk0p4/runlog.txt | grep -Fo 'C1C2C3A4A5A6A7A8' | uniq"
	[ -z "$CAN2" ] && \
	echo "[FAIL] Verify CAN2 can be connected to MCU via echo command " >> "${tmp_}" || \
	echo "[PASS] Verify CAN2 can be connected to MCU via echo command " >> "${tmp_}"
	
	
	sleep 1

	echo "TEST_STOP" > /opt/sfifo
}



#main 

setup
sleep 40

hw_Check
sleep 1

internet_check
sleep 1

ethernet_check
sleep 1

#WIFI_check
sleep 1

SW
sleep 1

CAN
sleep 1

result 



