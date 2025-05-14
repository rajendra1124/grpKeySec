# gnb.py
import socket, logging, os
import subprocess

logging.basicConfig(filename='gnb.log', level=logging.DEBUG)

def receive_from_ue():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.bind(('', 9000))
    data, _ = s.recvfrom(1024)
    logging.info("Received registration from UE")
    return data

def send_to_amf(data):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.sendto(data, ('192.168.0.2', 9001))
    logging.info("Forwarded to AMF")

# def setup_gtp():
#     os.system("ip link add gtp0 type gtp")
#     os.system("ip addr add 10.0.0.1/24 dev gtp0")
#     os.system("ip link set gtp0 up")
#     logging.info("GTP tunnel created")

def setup_gtp():
    try:
        subprocess.run(["ip", "link", "add", "gtp0", "type", "gtp"], check=True)
        subprocess.run(["ip", "addr", "add", "10.1.1.1/24", "dev", "gtp0"], check=True)
        subprocess.run(["ip", "link", "set", "gtp0", "up"], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error setting up GTP: {e}")

data = receive_from_ue()
send_to_amf(data)
setup_gtp()
