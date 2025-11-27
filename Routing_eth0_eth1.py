import subprocess
import logging

logging.basicConfig(filename='ping_tracert.log', level=logging.DEBUG)

# 要 ping 的 IP 地址
ip_list = ["10.0.0.1", "192.168.5.5"]

# 定義 tracert_cmd
tracert_cmd = ["tracert", "-h", "3", "8.8.8.8"]
tracert_cmd_1 = ["tracert", "-h", "3", "61.216.146.85"]
tracert_cmd_2 = ["tracert", "-h", "3", "185.30.211.154"]
# 遍歷 IP 列表，逐一 ping 和 tracert
for ip in ip_list:
    try:
   
        logging.info(f"Tracert 8.8.8.8...")
        result_tracert = subprocess.run(tracert_cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
        result_tracert_1 = subprocess.run(tracert_cmd_1, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
        result_tracert_2 = subprocess.run(tracert_cmd_2, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)

        # 列印 tracert 結果
        print(f"Tracert Result for {ip}:")
        print(result_tracert.stdout)
        print(result_tracert_1.stdout)
        print(result_tracert_2.stdout)

        # 將 tracert 結果寫入 log 檔案
        logging.debug(f"Tracert Result for {ip}:")
        logging.debug(result_tracert.stdout)
        logging.debug(result_tracert_1.stdout)
        logging.debug(result_tracert_2.stdout)

    except subprocess.CalledProcessError as e:
        error_msg = f"Failed to ping {ip}, Error: {e}"
        logging.error(error_msg)
        print(error_msg)