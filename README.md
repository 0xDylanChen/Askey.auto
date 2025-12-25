# Askey Auto Project Tools

這個專案包含了一系列用於 Askey 車載單元 (OBU - On-Board Unit) 的測試、自動化與工具腳本。主要功能涵蓋 MQTT 通訊測試、系統整合測試 (SIT)、Smoke Test 以及一些檔案處理工具。

## 專案內容

### 1. System Integration Test (SIT) Tool
*   **檔案:** `SIT_function_tool_v001.py`
*   **功能:** 這是一個提供圖形化介面 (GUI) 的綜合測試工具。
    *   **Upload OBU Demo File:** 透過 SSH/SFTP 將測試腳本 (`obu_demo.sh`) 上傳至設備。
    *   **MQTT Update:** 執行韌體更新 (OTA) 流程，包含計算檔案雜湊值 (Hash)、發送 MQTT 更新指令，並監控更新進度。
    *   **Function Test:** (部分功能) 包含 COM Port 連線及基本功能測試介面。
*   **依賴:** `tkinter`, `paramiko`, `hashlib`, `subprocess`, `mosquitto` (外部執行檔)

### 2. MQTT Function Tester
*   **檔案:** `MQTT_function.py`, `MQTT_function _sub.py`
*   **功能:** 用於發送與接收 MQTT 訊息的工具。
    *   支援多種預定義的 Payload，包括：Reboot, GNSS 設定, WiFi 設定, Wakeup, OTA, BLE, WWAN 路由控制等。
    *   可選擇特定的 Topic 進行發布 (Publish) 或訂閱 (Subscribe)。
*   **依賴:** `tkinter`, `mosquitto_pub.exe`, `mosquitto_sub.exe`

### 3. OBU Smoke Test Script
*   **檔案:** `OBU_SmokeTest_V001.sh`
*   **功能:** 在 OBU 設備端執行的 Shell Script，用於快速驗證硬體與軟體功能是否正常 (Smoke Test)。
    *   **Hardware Check:** NTP 同步, SPI Flash, DRAM, eMMC, USB OTG, HSM, IMU Sensor。
    *   **Network Check:** Internet (IPv4/IPv6), Ethernet (eth0/eth1), WiFi (AP Mode)。
    *   **Software Check:** GPS 定位, Bluetooth, V2X 通訊, Audio 輸出。
    *   **CAN Bus:** CAN 介面回環測試。

### 4. Network Routing Utility
*   **檔案:** `Routing_eth0_eth1.py`
*   **功能:** 執行 `tracert` 指令以驗證網路路由路徑 (如連線至 8.8.8.8)。
*   **輸出:** 結果會記錄在 `ping_tracert.log` 中。

### 5. File Utilities
*   **檔案:**
    *   `textfile_to_pythonfile.py`: 將指定目錄下的 `.txt` 檔案批次重新命名為 `.py`。
    *   `wordfile_to_pdffile.py`: 將當前目錄下的 Word (`.docx`) 檔案批次轉換為 PDF。
*   **依賴:** `docx2pdf` (需安裝: `pip install docx2pdf`)

## 環境需求

*   **Python:** 3.x
*   **Python Libraries:**
    ```bash
    pip install paramiko docx2pdf
    ```
    (注意: `tkinter` 通常內建於 Python 安裝中)
*   **外部工具:**
    *   `mosquitto_pub` 和 `mosquitto_sub`: 需安裝 Mosquitto MQTT Broker 並確保執行檔在系統路徑中，或是與腳本位於同一目錄。

## 使用說明

1.  **SIT Tool:** 執行 `python SIT_function_tool_v001.py` 啟動 GUI，依據選單選擇所需功能。
2.  **MQTT Test:** 執行 `python MQTT_function.py`，依照終端機提示選擇要發送的 Topic 與 Payload。
3.  **Smoke Test:** 將 `OBU_SmokeTest_V001.sh` 複製到設備端 (如 `/home/root/`) 並給予執行權限 (`chmod +x`) 後執行。

## 注意事項

*   部分腳本中寫死了 IP 位址 (如 `10.0.0.1`) 與帳號密碼，使用前請根據實際環境進行修改。
*   MQTT 相關功能依賴 Windows 環境下的 `mosquitto_pub.exe` 與 `mosquitto_sub.exe`，請確保環境配置正確。
