import os
import sys
import paramiko

#checksum
import zlib
import binascii

#hash256
import hashlib
import subprocess




# 取得參數
source_file = sys.argv[1]
dest_folder = "/run/media/mmcblk0p4/ftp_root/shared/"
remote_host = "10.0.0.1"
remote_port = 8822
remote_username = "root"
remote_password = "Askey+1937"


source_file = sys.argv[1]
#hash
print("hash counting...")
with open(source_file, 'rb') as f:
    file_hash = hashlib.sha256()
    while chunk := f.read(8192):
        file_hash.update(chunk)
    sha256_hash = file_hash.hexdigest()

mqtt_ad = "admin"
mqtt_pwd = "admin"
mqtt_ip = "10.0.0.1"
port = 1883
mqtt_topic = "TextCommand/Request/OTAFirmwareUpdate/v1/All/v1"
id = "admin"



#checksum
print("checksum counting...")
n_checksum_mqtt_message = "{\"header\":{\"schemaName\":\"JSON\",\"magic\":\"\",\"timestamp\":{\"sec\":1628071772,\"nsec\":664227000},\"streamHandler\":{\"streamID\":0,\"seqNum\":0},\"chksum\":0},\"payloadType\":\"JSON\",\"payload\":{\"username\":\"mobileye\",\"password\":\"mobileye\",\"firmwareName\":\"" + source_file + "\",\"firmwareHash\":\"" + sha256_hash + "\"}}"
payload_string = str(n_checksum_mqtt_message)
# Print the checksum in hexadecimal format
checksum = hex(zlib.crc32(n_checksum_mqtt_message.encode()))
checksum_meg = checksum[:2] + checksum[2:].upper()


mqtt_message = "{\\\"header\\\":{\\\"schemaName\\\":\\\"JSON\\\",\\\"magic\\\":\\\"\\\",\\\"timestamp\\\":{\\\"sec\\\":1628071772,\\\"nsec\\\":664227000},\\\"streamHandler\\\":{\\\"streamID\\\":0,\\\"seqNum\\\":0},\\\"chksum\\\":\\\"" + checksum_meg + "\\\"},\\\"payloadType\\\":\\\"JSON\\\",\\\"payload\\\":{\\\"username\\\":\\\"mobileye\\\",\\\"password\\\":\\\"mobileye\\\",\\\"firmwareName\\\":\\\"" + source_file + "\\\",\\\"firmwareHash\\\":\\\"" + sha256_hash + "\\\"}}"

# set mqtt 02.11.393
cmd = f'mosquitto_pub.exe -u {mqtt_ad} -P {mqtt_pwd} -h {mqtt_ip} -t "{mqtt_topic}" -m "{mqtt_message}"'
print("Setup update config and data ....")
os.system(cmd)

# 建立SSH連線
print ("Uploading FOTA File")
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(remote_host, port=remote_port, username=remote_username, password=remote_password)
# 建立SFTP連線
sftp = ssh.open_sftp()

# 上傳檔案
sftp.put(source_file, dest_folder + os.path.basename(source_file))

# 關閉SFTP連線與SSH連線
sftp.close()
ssh.close()

#START 
mqtt_start_message = "{\\\"header\\\":{\\\"schemaName\\\":\\\"JSON\\\",\\\"magic\\\":\\\"\\\",\\\"timestamp\\\":{\\\"sec\\\":1628071772,\\\"nsec\\\":664227000},\\\"streamHandler\\\":{\\\"streamID\\\":0,\\\"seqNum\\\":0},\\\"chksum\\\":\\\"0xCA2BFFF5\\\"},\\\"payloadType\\\":\\\"JSON\\\",\\\"payload\\\":{\\\"updateCmd\\\":\\\"start\\\"}}"

cmd_start = f'mosquitto_pub.exe -u {mqtt_ad} -P {mqtt_pwd} -h {mqtt_ip} -t "{mqtt_topic}" -m "{mqtt_start_message}"'
start_update = "start_update please check OBU FWUpdate process"
print(start_update)
os.system(cmd_start)

