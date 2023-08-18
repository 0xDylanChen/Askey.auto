#GUI
import tkinter as tk

#sysoutput
import os

#path
import sys

#sftp 
import paramiko

#checksum
import zlib
import binascii

#hash256
import hashlib

#process
import subprocess

# threading
import threading

#time
import datetime
import time 
import json

pub_topic = [
    "/vehicle/info",#1
    "TextCommand/Request/GNSS/v1/Settings/v1", #2
    "TextCommand/Request/WWAN/v1/Settings/v1", #3
    "TextCommand/Request/WAKEUP/v1/Settings/v1", #4
    "TextCommand/Request/REBOOT/v1/Settings/v1", #5
    "TextCommand/Request/MQTT/v1/Settings/v1", #6
    "TextCommand/Request/OTAFirmwareUpdate/v1/All/v1", #7
    "TextCommand/Request/OTA/v1/Settings/v1", #8
    "TextCommand/Request/WIFI/v1/Settings/v1", #9
    "GEN/Request/v1", #10
    "GEN/Response/v1", #11
    "LOG/tcuapp", #12
    "ble", #13
    ]
sub_topic = ["/v2x/gnss",
    "TextNotification/OBUStatus/v1/All/v1", #1
    "TextCommand/Response/OTA/v1/Settings/v1", #2
    "TextCommand/Response/WAKEUP/v1/Settings/v1", #3
    "TextCommand/Response/WWAN/v1/Settings/v1", #4
    "TextCommand/Response/BLE/v1/Settings/v1", #5
    "TextCommand/Response/WIFI/v1/Settings/v1", #6
    "TextCommand/Response/GNSS/v1/Settings/v1", #7
    "TextCommand/Response/REBOOT/v1/Settings/v1", #8
    "TextCommand/Response/OTAFirmwareUpdate/v1/All/v1", #9
    "TextCommand/Response/MQTT/v1/Settings/v1", #10
    "/bsm/signal/", #11
    "/vehicle/info", #12
    "TextCommand/Response/eCall/v1/All/v1", #13
    "TextCommand/Response/TLS/v1/Settings/v1", #14
    "TextCommand/Request/WAKEUP/v1/Settings/v1", #15
    "TextCommand/Request/WWAN/v1/Settings/v1", #16
    "GEN/Request/v1", #17
    "GEN/Response/v1", #18
    "LOG/tcuapp ", #19
    "LOG/tcuapp"] #20

def pub_mqtt(topic, payload):
    message_tmp = {
    "header": {
        "schemaName": "JSON",
        "magic": "",
        "timestamp": {
            "sec": 1628071792,
            "nsec": 64227000
        },
        "streamHandler": {
            "streamID": 0,
            "seqNum": 0
        },
        "chksum": 0
    },
    "payloadType": "JSON",
    "payload": None
}
    message_tmp["payload"] = payload

    json_string = json.dumps(message_tmp, separators=(',', ':')) 
    checksum = hex(zlib.crc32(json_string.encode()))
    checksum_meg_1 = checksum[2:].upper()  
    message_tmp["header"]["chksum"] = f'0x{checksum_meg_1}'

    message_tmp = json.dumps(message_tmp)
    print(message_tmp)

    json_string_escaped = message_tmp.replace('"', '\\"')

    doit = f'mosquitto_pub.exe -u {mqtt_ad} -P {mqtt_pwd} -h {mqtt_ip} -t "{topic}" -m "{json_string_escaped}"'
    os.system(doit)

def MQTT_fnc():
    reboot_payload = {
    "rebootSystem" : True,
    "factoryReset" : True
    }
    GNSS_payload = {
        "TLSEnable": False,
		"reportFrequency": 10
    }
    WIFI_payload = {
        "enable": True,
    "mode": "AP",
    "AP": [
      {
        "enable": True,
        "band": "2.4G",
        "SSID": "CTX0800_AP2G_SIT1",
        "password": "123456789",
        "keySet": "WPA2"
      },
      {
        "enable": True,
        "band": "5G",
        "SSID": "CTX0800_AP5G_SIT1",
        "password": "123456789",
        "keySet": "WPA2"
      }
    ],
    "STA": {
      "SSID": "Askey-00M05-5G",
      "password": "12345678"
    }
    }
    wakeup_payload = {
        "ECU_WOL":
        {"enable":False,"mac":""},
        "wakeupDestination":"GPIO",
        "wakeupSource":[{"type":"SMS",
                         "enable":True,
                         "condition":[{"from":"",
                                        "content":""},
                                    {"from":"886905051048",
                                        "content":"2"},
                                    {"from":"0905051048",                                                    
                                        "content":"3"
    }]}]
    }
    ota_payload = {
    "OTAFirmwareUpdateEnable":False,
    "localSFTPEnable":True 
    }
    ble_payload = { 
    "enable":True
    }
    wwlan_payload = {
    '''
    "SPE":{"IP":"192.168.19.195","MASK":"255.255.255.0"},
    "RJ45":{"IP":"10.0.0.1","MASK":"255.255.255.0"},
    "VLANControl":{"VLAN1":{"VID":"15","IPv4":"176.16.15.1/24"},
                   "VLAN2":{"VID":"25","IPv4":"176.16.25.1/24"},
                   "MQTT":"VLAN1","NTP":"VLAN2"}
    '''
    "VLANControl":{"VLAN1":{"VID":"0","IPv4":"0/32"},
                   "VLAN2":{"VID":"0","IPv4":"0/32"},
                   "MQTT":"VLAN1","NTP":"VLAN2"},
    "5GConnectivity":True,
    "cellularNetwork":True,
    "APN":[{"modem0":["internet"]},
           {"modem1":["internet"]}],
           "DSDAControl":["modem0","modem1"],
           "routingControl":[{"sourceInterface":"eth0","destIP":"null","destInterface":"modem0"},
                            {"sourceInterface":"eth1","destIP":"null","destInterface":"modem0"}]
                
    }
    log_payload = {
        "5Gloglevel":1,"FWloglevel":1,"MCUloglevel":1,"APIloglevel":1,"MQTTloglevel":1
    }
    ssh_payload = {
        "SSHD":"START"
    }
    vehicle_speed_payload = {"speed":27.77,"transmission":1,"timestamp":123456}
    mqtt_payload = {}
    fwu_payload = {}


    for i in range(len(pub_topic)): 
        print(f"{i+1}.  {pub_topic[i]}")

    publist_t = input("choice you want pub topic ")
    publist = int(publist_t) - 1
    if publist == 0 :
        pub_mqtt(pub_topic[publist],vehicle_speed_payload)
    elif publist == 1 :
        pub_mqtt(pub_topic[publist],GNSS_payload)
    elif publist == 2 :
        pub_mqtt(pub_topic[publist],wwlan_payload)
    elif publist == 3 :
        pub_mqtt(pub_topic[publist],wakeup_payload)
    elif publist == 4 :
        pub_mqtt(pub_topic[publist],reboot_payload)
    elif publist == 5 :
        pub_mqtt(pub_topic[publist],mqtt_payload)
    elif publist == 6 :
        pub_mqtt(pub_topic[publist],fwu_payload)
    elif publist == 7 :
        pub_mqtt(pub_topic[publist],ota_payload)
    elif publist == 8 :
        pub_mqtt(pub_topic[publist],WIFI_payload)
    elif publist == 9 :
        pub_mqtt(pub_topic[publist],reboot_payload)
    elif publist == 10 :
        pub_mqtt(pub_topic[publist],ssh_payload)
    elif publist == 11 :
        pub_mqtt(pub_topic[publist],None)
    elif publist == 12 :
        pub_mqtt(pub_topic[publist],log_payload)
    elif publist == 13 :
        pub_mqtt(pub_topic[publist],ble_payload)
    elif publist == 14 :
        pub_mqtt(pub_topic[publist],None)
    elif publist == 15 :
        pub_mqtt(pub_topic[publist],None)
    elif publist == 16 :
        pub_mqtt(pub_topic[publist],None)
    else :
        print('input fail number and one charator')
    print('done')


def mqtt_fnc_sub():
    #sub
    for i in range(len(sub_topic)):
        print(f"{i+1}.  {sub_topic[i]}")
    
    sublist = input("choice you want sub topic ex: 1 2 3 4\n")
    sublist = sublist.split()

    Tthread_sub = []

    for j in range(len(sublist)):
        index = int(sublist[j]) - 1 
        print(f"{j+1}.  {sub_topic[index]}")
        cmd_sub_start = f'mosquitto_sub.exe -u {mqtt_ad} -P {mqtt_pwd} -h {mqtt_ip} -t "{sub_topic[index]}"'
        proc = subprocess.Popen(cmd_sub_start, shell=True, stdout=subprocess.PIPE)
        thread = threading.Thread(target=execute_command, args=(cmd_sub_start,))
        Tthread_sub.append(thread)
        thread.start()

    for thread in Tthread_sub:
        thread.join()

def execute_command(command):
    proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    for line in proc.stdout:
        print(line.decode().strip())

mqtt_ad = "admin"
mqtt_pwd = "admin"
mqtt_ip = "10.0.0.1"
port = 1883

def main():
    thread_sub = threading.Thread(target=mqtt_fnc_sub)
    thread_sub.start()
    #MQTT_fnc()
    
if __name__ == '__main__' :
    main()


