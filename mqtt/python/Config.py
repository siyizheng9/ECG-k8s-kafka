import os


class Config():
    client_id = os.getenv('MQTT_CLIENT_ID', 'python_client')
    time_interval = os.getenv('MQTT_PUB_TIME_INTERVAL', 2)
    mqtt_server = os.getenv('MQTT_HOST', '192.168.1.103')
    mqtt_port = os.getenv('MQTT_PORT', 30830)
    path_sample_data = os.getenv('MQTT_SAMPLE_DATA',
                                 '/home/zheng/ecg_data/sample_data.csv')
    mqtt_topic = "ecg/test/" + client_id + "/" + "data"
    repeat_test = os.getenv('MQTT_REPEAT_TEST', 3)
