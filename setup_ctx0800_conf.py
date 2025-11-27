import os
import sys
import json

def setup_loglevel(conf):
    conf['5G settings']['LOG_LEVEL'] = 0
    conf['CMQTTManager settings']['LOG_LEVEL'] = 5
    conf['FwUpdate settings']['LOG_LEVEL'] = 5
    conf['MCUManager settings']['LOG_LEVEL'] = 1
    conf['MobileyeManager settings']['LOG_LEVEL'] = 5
    conf['PowerHandler']['LOG_LEVEL'] = 5
    conf['SMS settings']['LOG_LEVEL'] = 5
    conf['Time settings']['LOG_LEVEL'] = 5
    conf['VLANControl']['LOG_LEVEL'] = 5
    conf['WifiManager settings']['LOG_LEVEL'] = 5

def setup_wifi_ap(conf):
    conf['WifiManager settings']['AP2G SSID'] = 'CTX0800_2G'
    conf['WifiManager settings']['AP2G password'] = '12345678'
    conf['WifiManager settings']['AP2G enable'] = True
    conf['WifiManager settings']['AP5G SSID'] = 'CTX0800_5G'
    conf['WifiManager settings']['AP5G password'] = '12345678'
    conf['WifiManager settings']['AP5G enable'] = True
    conf['WifiManager settings']['Enabled'] = True

def setup_https_test_url(conf):
    conf['5G settings']['HTTPS_TEST'] = 'https://google.com'

def setup_ctx0800_conf(ctx0800_conf_path):
    with open(ctx0800_conf_path, 'r') as fr:
        ctx0800_conf = json.load(fr)
        setup_loglevel(ctx0800_conf)
        setup_wifi_ap(ctx0800_conf)
        setup_https_test_url(ctx0800_conf)
        with open(ctx0800_conf_path, 'w') as fw:
            fw.write(json.dumps(ctx0800_conf, separators=(',', ':'), indent=2, sort_keys=True))

if __name__ == '__main__':
    try:
        setup_ctx0800_conf('/run/media/mmcblk0p4/conf/ctx0800.conf')
        print('OK')
    except Exception as ex:
        print(ex)
        print('NG')
