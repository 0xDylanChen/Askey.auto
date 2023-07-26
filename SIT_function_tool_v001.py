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

def parameter():
    # 確保至少有一個參數傳入
    if len(sys.argv) < 2:
        print("Usage: python myPython.py arg1,arg2,arg3")
        return

    # 取得第一個參數，這是包含多個數字的字串
    global source_file
    source_file = sys.argv[1]

# get current path
current_dir = os.getcwd()

#C1, C2
def func_ssh(dest_folder,upload_file):
    
    remote_host = "10.0.0.1"
    remote_port = 8822
    remote_username = "root"
    remote_password = "Askey+1937"
    
    # 建立SSH連線
    text.insert(tk.END, "10.0.0.1 Connecting \n")    
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(remote_host, port=remote_port, username=remote_username, password=remote_password, timeout=10)
    except paramiko.ssh_exception.SSHException as e:
        text.insert(tk.END, f"SSH connection failed: {e} \n")
        ssh.close()
        return

    # 建立SFTP連線
    sftp = ssh.open_sftp()
    
    if ssh.get_transport().is_active():
        text.insert(tk.END, "10.0.0.1 Connect success \n")
    else: 
        text.insert(tk.END, "10.0.0.1 Connect Fail \n")
        sftp.close()
        return
        
        
    # 上傳檔案
    transfer_result = sftp.put(upload_file, dest_folder + os.path.basename(upload_file))
    
    if transfer_result is not None:
        text.insert(tk.END, f"Upload file successfully \n {transfer_result} \n")
    else:
        text.insert(tk.END, f"Upload file failed: \n {transfer_result} \n")
    # 關閉SFTP連線與SSH連線
    sftp.close()
    ssh.close()
    time.sleep(3)
 
def MQTT_Fota():
    #into path
    os.chdir('OBU_Firmware')   
    
    #hash python3.8
    print("Execute file hash ....")
    with open(source_file, 'rb') as f:
        file_hash = hashlib.sha256()
        while chunk := f.read(8192):
            file_hash.update(chunk)
        sha256_hash = file_hash.hexdigest()
    
    #mqtt 
    mqtt_ad = "admin"
    mqtt_pwd = "admin"
    mqtt_ip = "10.0.0.1"
    port = 1883
    mqtt_topic = "TextCommand/Request/OTAFirmwareUpdate/v1/All/v1"
    id = "admin"

    pub_topic_sftp = "TextCommand/Request/OTA/v1/Settings/v1"
    #enable SFTP & mqttupdate
    sftp_mqttupdate_message = "{\\\"header\\\":{\\\"schemaName\\\":\\\"JSON\\\",\\\"magic\\\":\\\"ef58ea3f-5559-466e-8b2d-6b9a3f000010\\\",\\\"timestamp\\\":{\\\"sec\\\":1628071772,\\\"nsec\\\":664227000},\\\"streamHandler\\\":{\\\"streamID\\\":0,\\\"seqNum\\\":0},\\\"chksum\\\":\\\"0x7E35B8FE\\\"},\\\"payloadType\\\":\\\"JSON\\\",\\\"payload\\\":{\\\"OTAFirmwareUpdateEnable\\\":true,\\\"localSFTPEnable\\\":true}}"

    sftp_update = f'mosquitto_pub.exe -u {mqtt_ad} -P {mqtt_pwd} -h {mqtt_ip} -t "{pub_topic_sftp}" -m "{sftp_mqttupdate_message}"'
    print("enable SFTP and update control\n")
    os.system(sftp_update)
    print(f"SFTP enable : \n {sftp_update} \n ")

    #checksum
    print("checksum counting...\n")
    n_checksum_mqtt_message = "{\"header\":{\"schemaName\":\"JSON\",\"magic\":\"\",\"timestamp\":{\"sec\":1628071772,\"nsec\":664227000},\"streamHandler\":{\"streamID\":0,\"seqNum\":0},\"chksum\":0},\"payloadType\":\"JSON\",\"payload\":{\"username\":\"mobileye\",\"password\":\"mobileye\",\"firmwareName\":\"" + source_file + "\",\"firmwareHash\":\"" + sha256_hash + "\"}}"
    payload_string = str(n_checksum_mqtt_message)
    # Print the checksum in hexadecimal format
    checksum = hex(zlib.crc32(n_checksum_mqtt_message.encode()))
    checksum_meg = checksum[:2] + checksum[2:].upper()


    mqtt_message = "{\\\"header\\\":{\\\"schemaName\\\":\\\"JSON\\\",\\\"magic\\\":\\\"\\\",\\\"timestamp\\\":{\\\"sec\\\":1628071772,\\\"nsec\\\":664227000},\\\"streamHandler\\\":{\\\"streamID\\\":0,\\\"seqNum\\\":0},\\\"chksum\\\":\\\"" + checksum_meg + "\\\"},\\\"payloadType\\\":\\\"JSON\\\",\\\"payload\\\":{\\\"username\\\":\\\"mobileye\\\",\\\"password\\\":\\\"mobileye\\\",\\\"firmwareName\\\":\\\"" + source_file + "\\\",\\\"firmwareHash\\\":\\\"" + sha256_hash + "\\\"}}"


    # set mqtt
    cmd = f'mosquitto_pub.exe -u {mqtt_ad} -P {mqtt_pwd} -h {mqtt_ip} -t "{mqtt_topic}" -m "{mqtt_message}"'
    print("Setup update config and data ....\n")

    # 切換至目標目錄 
    dest_folder = "/run/media/mmcblk0p4/ftp_root/shared/"
    # 建立SSH連線
    func_ssh(dest_folder,source_file)


#START 
    mqtt_start_message = "{\\\"header\\\":{\\\"schemaName\\\":\\\"JSON\\\",\\\"magic\\\":\\\"\\\",\\\"timestamp\\\":{\\\"sec\\\":1628071772,\\\"nsec\\\":664227000},\\\"streamHandler\\\":{\\\"streamID\\\":0,\\\"seqNum\\\":0},\\\"chksum\\\":\\\"0xCA2BFFF5\\\"},\\\"payloadType\\\":\\\"JSON\\\",\\\"payload\\\":{\\\"updateCmd\\\":\\\"start\\\"}}"
    cmd_start = f'mosquitto_pub.exe -u {mqtt_ad} -P {mqtt_pwd} -h {mqtt_ip} -t "{mqtt_topic}" -m "{mqtt_start_message}"'
    print("start_update please check OBU FWUpdate process....\n")
    os.system(cmd_start)
    
    #back to path
    os.chdir(current_dir)

#FOTA_MQTT Output   
def MQTT_sub_result(): 
    #sub
    sub_topic = "TextCommand/Response/OTAFirmwareUpdate/v1/All/v1"
    cmd_sub_start = f'mosquitto_sub.exe -u {mqtt_ad} -P {mqtt_pwd} -h {mqtt_ip} -t "{sub_topic}"'
    
       # subprocess mosquitto_sub
    proc = subprocess.Popen(cmd_sub_start, shell=True, stdout=subprocess.PIPE)
    
    #start time
    currentTime = datetime.datetime.now()
        # keep read from mosquitto_sub output.
    while True:
        line = proc.stdout.readline().decode()
        if not line:
            break
        text.insert(tk.END, line)  
        if "Finished" in line:
            
            print("UPDATE SUCCESS....\n")
            time_counting(currentTime)
            break

        elif "false" in line:
            
            print("UPDATE FAIL ....\n")
            time_counting(start_time)
            break
        
        elif "Check Image" in line and "error\":\"none" in line:
            
            print("Check Image ....\n")

        elif "Unpack" in line and "error\":\"none" in line:
            
            print("Unpack FOTA file....\n")
            
        elif "Update SoC" in line and "error\":\"none" in line:
            print("UPDATE SOC....\n")

        elif "Update MCU" in line and "error\":\"none" in line:
            print("UPDATE MCU....\n")

        elif "Update MODEM" in line and "error\":\"none" in line:
            time_counting(currentTime)
            print( "UPDATE MODEM....\n")

    #file_list = os.listdir(target_dir)

#time function
start_time = 0 
end_time = 0

def time_counting(start_time):
    end_time = datetime.datetime.now()
    time_diff = end_time - start_time
    print(f"{str(time_diff)}.. <- Update Spend time ..\n")



def main():
    parameter()
    subprocess.Popen(MQTT_sub_result(), shell=True, stdout=subprocess.PIPE)
    MQTT_Fota()

if __name__ == "__main__":
    main()