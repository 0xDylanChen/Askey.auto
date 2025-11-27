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

# 取得當前目錄
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
 
def func_a1():
    
    path_Upload = 'obu_demo.sh'
    dest_folder = "/home/root/"
    # 切換至目標目錄
    
    os.chdir('RunSITscripe')    
    
    check_path = os.path.basename(os.getcwd())
    text.insert(tk.END, f"{check_path}\n" )
    
    if check_path == 'RunSITscripe':
        text.insert(tk.END, "Switch to directory RunSITscripe successfully.\n")
    else:
        text.insert(tk.END, "Failed to switch to directory RunSITscripe.\n")
        
    # 建立SSH連線
    func_ssh(dest_folder,path_Upload)

    os.chdir(current_dir)    

def func_a2():
    #into path
    os.chdir('OBU_Firmware')   
    
    #hash python3.8
    text.insert(tk.END, "hash counting...\n")
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
    text.insert(tk.END, "enable SFTP and update control\n")
    os.system(sftp_update)
    text.insert(tk.END, f"SFTP enable : \n {sftp_update} \n ")

    #checksum
    text.insert(tk.END, "checksum counting...\n")

    n_checksum_mqtt_message = "{\"header\":{\"schemaName\":\"JSON\",\"magic\":\"\",\"timestamp\":{\"sec\":1628071772,\"nsec\":664227000},\"streamHandler\":{\"streamID\":0,\"seqNum\":0},\"chksum\":0},\"payloadType\":\"JSON\",\"payload\":{\"username\":\"mobileye\",\"password\":\"mobileye\",\"firmwareName\":\"" + source_file + "\",\"firmwareHash\":\"" + sha256_hash + "\"}}"
    payload_string = str(n_checksum_mqtt_message)
    # Print the checksum in hexadecimal format
    checksum = hex(zlib.crc32(n_checksum_mqtt_message.encode()))
    checksum_meg = checksum[:2] + checksum[2:].upper()


    mqtt_message = "{\\\"header\\\":{\\\"schemaName\\\":\\\"JSON\\\",\\\"magic\\\":\\\"\\\",\\\"timestamp\\\":{\\\"sec\\\":1628071772,\\\"nsec\\\":664227000},\\\"streamHandler\\\":{\\\"streamID\\\":0,\\\"seqNum\\\":0},\\\"chksum\\\":\\\"" + checksum_meg + "\\\"},\\\"payloadType\\\":\\\"JSON\\\",\\\"payload\\\":{\\\"username\\\":\\\"mobileye\\\",\\\"password\\\":\\\"mobileye\\\",\\\"firmwareName\\\":\\\"" + source_file + "\\\",\\\"firmwareHash\\\":\\\"" + sha256_hash + "\\\"}}"


    # set mqtt
    cmd = f'mosquitto_pub.exe -u {mqtt_ad} -P {mqtt_pwd} -h {mqtt_ip} -t "{mqtt_topic}" -m "{mqtt_message}"'
    text.insert(tk.END, f"Setup update config and data ....\n {cmd} \n ")


    # 切換至目標目錄 
    dest_folder = "/run/media/mmcblk0p4/ftp_root/shared/"
    # 建立SSH連線
    func_ssh(dest_folder,source_file)


#START 
    mqtt_start_message = "{\\\"header\\\":{\\\"schemaName\\\":\\\"JSON\\\",\\\"magic\\\":\\\"\\\",\\\"timestamp\\\":{\\\"sec\\\":1628071772,\\\"nsec\\\":664227000},\\\"streamHandler\\\":{\\\"streamID\\\":0,\\\"seqNum\\\":0},\\\"chksum\\\":\\\"0xCA2BFFF5\\\"},\\\"payloadType\\\":\\\"JSON\\\",\\\"payload\\\":{\\\"updateCmd\\\":\\\"start\\\"}}"
    text.insert(tk.END, f"START!!...\n {mqtt_start_message} \n")
    cmd_start = f'mosquitto_pub.exe -u {mqtt_ad} -P {mqtt_pwd} -h {mqtt_ip} -t "{mqtt_topic}" -m "{mqtt_start_message}"'
    text.insert(tk.END, "start_update please check OBU FWUpdate process....\n")
    os.system(cmd_start)
    
    #back to path
    os.chdir(current_dir)
    
    #sub
    sub_topic = "TextCommand/Response/OTAFirmwareUpdate/v1/All/v1"
    cmd_sub_start = f'mosquitto_sub.exe -u {mqtt_ad} -P {mqtt_pwd} -h {mqtt_ip} -t "{sub_topic}"'
    
       # 創建一個子進程來執行 mosquitto_sub 命令
    proc = subprocess.Popen(cmd_sub_start, shell=True, stdout=subprocess.PIPE)
    
    #start time
    start_time = datetime.datetime.now()

        # 持續讀取 mosquitto_sub 的輸出，並將其插入到 GUI 文本框中
    while True:
        line = proc.stdout.readline().decode()
        if not line:
            break
        text.insert(tk.END, line)  
        if "Finished" in line:
            text.insert(tk.END, "UPDATE SUCCESS....\n")
            label_display.configure(text="UPDATE SUCCESS ....")

            end_time = datetime.datetime.now()
            time_counting(start_time)
            break

        elif "false" in line:
            text.insert(tk.END, "UPDATE FAIL....\n")
            label_display.configure(text="UPDATE FAIL ....")
            end_time = datetime.datetime.now()
            time_counting(start_time)
            break
        
        elif "Check Image" in line and "error\":\"none" in line:
            text.insert(tk.END, "Check Image....\n")
            time_counting(start_time)
            label_display.configure(text="Check Image ....")
        elif "Unpack" in line and "error\":\"none" in line:
            text.insert(tk.END, "Unpack FOTA file....\n")
            time_counting(start_time)
            label_display.configure(text="Unpack Image ....")
            
        elif "Update SoC" in line and "error\":\"none" in line:
            text.insert(tk.END, "UPDATE SOC....\n")
            time_counting(start_time)
            label_display.configure(text="UPDATE SOC ....")
        elif "Update MCU" in line and "error\":\"none" in line:
            text.insert(tk.END, "UPDATE MCU....\n")
            time_counting(start_time)
            label_display.configure(text="UPDATE MCU ....")
        elif "Update MODEM" in line and "error\":\"none" in line:
            text.insert(tk.END, "UPDATE MODEM....\n")
            time_counting(start_time)
            label_display.configure(text="UPDATE MODEM ....")
start_time = 0 
end_time = 0

#C2
def time_counting(start_time):
    end_time = datetime.datetime.now()
    time_diff = end_time - start_time
    text.insert(tk.END, f"{str(time_diff)}.. <- Update Spend time ..\n")
#C3
def function_com_():
    creat_function_btn(root)
#C3
def creat_function_btn(root):
    global option_menu, connect_button
    global button1, button2, button3
    # 設定下拉式選單選項
    comports = list(serial.tools.list_ports.comports())
    comport_names = [c[0] for c in comports]

    # 創建變數，用於存儲選擇的 com port
    selected_comport = tk.StringVar(root)
    selected_comport.set(comport_names[0])
    
    # 創建下拉式選單
    option_menu = tk.OptionMenu(root, selected_comport, *comport_names)
    option_menu.grid(row=10, column=0, padx=0, pady=(10,5), sticky='W')

    # 創建按鈕，用於連接 com port
    connect_button = tk.Button(root, text="Connect", command=lambda: function.connect_to_comport(selected_comport.get(), text))
    connect_button.grid(row=11, column=0, padx=10, pady=(10,5), sticky='W')
    
    # 創建三個按鈕，用於下命令    
    button1 = tk.Button(root, text="Basic function", command=ping_google)
    button2 = tk.Button(root, text="Longterm function", command=lambda: function.send_command(selected_comport.get(), "command2"))
    button3 = tk.Button(root, text="Stress function", command=lambda: function.send_command(selected_comport.get(), "command3"))
    button1.grid(row=0, column=10, padx=10, pady=(10,0), sticky="W")
    button2.grid(row=2, column=10, padx=10, pady=(10,0), sticky="W")                
    button3.grid(row=3, column=10, padx=10, pady=(10,0), sticky="W")
    
    # 建立Text小工具和按鈕
    global cmd_text, cmd_button
    cmd_text = tk.Text(root,width=150, height=1)
    cmd_text.grid(row=50, column=0, padx=10, pady=(10,0), sticky="W")
    cmd_text.bind("<Return>", lambda event: send_command())
    cmd_button = tk.Button(root, text="Send", command=send_command)
    cmd_button.grid(row=40, column=8, padx=10, pady=(10,0), sticky="W")
#C3 
def send_command():
    command = cmd_text.get("1.0", tk.END).encode()  
    # 讀取Text小工具中的文字，並轉換為bytes型態
    function.ser.write(command)  # 將文字傳送到com port
    cmd_text.delete("1.0", tk.END)
    var_write = "\r"  # 去除換行符號
    function.ser.write(var_write.encode())
#C3
def ping_google():    
    result = subprocess.run(["ping", "-n", "1", "8.8.8.8"], capture_output=True, text=True)

    if result.returncode == 0:
        text.insert(tk.END, "Ping PASS .\n", "error")
    else:
        output = result.stdout
        text.insert(tk.END, f"Ping FAIL {output} .\n", "error")
#C3
def ping_ethernet():    
    result = subprocess.run(["ping", "-n", "1", "10.0.0.1"], capture_output=True, text=True)

    if result.returncode == 0:
        text.insert(tk.END, "Ping PASS .\n", "error")
    else:
        output = result.stdout
        text.insert(tk.END, f"Ping FAIL {output} .\n", "error")


root = tk.Tk()
root.title("SIT test My tool for CTX0800")

#main
def main_interface_menu(var):
        
    text.insert(tk.END, f"Selected function: {var}\n")    
    if var == "Mqtt_update" :
        selected_mqttupdate()
    #functionText.com.py
    if var == "FunctionTest" :
        function_com_()
    
#main
def delete_button():
    
    # 刪除MQTT UPDATE選擇檔案按鈕和下拉式選單
    if option_menu_file.winfo_exists():
        option_menu_file.destroy()
    if button1.winfo_exists():
        button1.destroy()
    if button2.winfo_exists():
        button1.destroy()
    if button3.winfo_exists():
        button1.destroy()
    if option_menu.winfo_exists():
        button1.destroy()
    if connect_button.winfo_exists():
        button1.destroy()

#main
# default按鈕元件
default_button = tk.Button(root, text="Back to default ", command=delete_button)
default_button.grid(row=50, column=0, padx=10, pady=(10,20), sticky='E')

#main
# 建立下拉式選單元件
options = ["Upload obu demo file", "Mqtt_update", "FunctionTest"]

var = tk.StringVar(root)
var.set("Select Function")
option_menu = tk.OptionMenu(root, var, *options, command=main_interface_menu)
option_menu.grid(row=0, column=0, padx=1, pady=(1,0), sticky='W')

#main
# 建立按鈕元件，點擊後執行相對應的函數
def execute_function():
    if var.get() == "Upload obu demo file":
        threading.Thread(target=func_a1).start()
    elif var.get() == "Mqtt_update":
        threading.Thread(target=func_a2).start()
    #elif var.get() == "FunctionTest":
        #threading.Thread(target=func_a3).start()

#main
# execute按鈕元件
button = tk.Button(root, text="Execute Function", command=execute_function)
button.grid(row=45, column=0, padx=10, pady=(10,20), sticky='W')

#main
# 建立 Text 元件
text = tk.Text(root, width=100, height=20)
text.grid(row=30, column=0, padx=10, pady=(10,0), sticky='W')
text.tag_configure("error", foreground="red")

#C2
def selected_mqttupdate():
    # 設定目標目錄路徑
    target_dir = "OBU_Firmware"

    # 取得目標目錄下的所有檔案和子目錄名稱
    file_list = os.listdir(target_dir)

    # 建立下拉式選單元件選擇檔案名稱
    global var_file
    var_file = tk.StringVar(root)
    var_file.set("Select a file")
    global option_menu_file
    option_menu_file = tk.OptionMenu(root, var_file, *file_list, command=execute_select_file)
    option_menu_file.grid(row=10, column=0, padx=10, pady=(10,0), sticky='W')
    
    global label_display
    label_display = tk.Label(root, text="Status", font=("Arial", 18))
    label_display.grid(row=40, column=1, padx=5, pady=(10,0), sticky='WE')

#C2
def execute_select_file(var=None):
    global source_file
    source_file = var_file.get()
    # 顯示選擇的檔案名稱至 Text
    text.insert(tk.END, f"Selected file: {source_file}\n")

    ## 按鈕元件
   #global button_select_file
    #button_select_file = tk.Button(root, text="Select File", command=execute_select_file)
    #button_select_file.grid(row=20, column=0, padx=10, pady=(10,0), sticky='W')

# 進入主迴圈
root.mainloop()
    
