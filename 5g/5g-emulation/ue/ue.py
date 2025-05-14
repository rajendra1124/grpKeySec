# ue.py
import socket, time, logging, os

logging.basicConfig(filename='ue.log', level=logging.DEBUG)

def send_registration():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.sendto(b'UE_REG_REQUEST', ('10.0.0.10', 9000))
    logging.info("Sent registration to gNB")

def wait_for_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.bind(('', 8000))
    data, _ = s.recvfrom(1024)
    ip = data.decode()
    logging.info(f"Received IP: {ip}")
    os.system(f"ip addr add {ip}/24 dev eth0")  # simple example
    os.system("ip route add default via 10.0.0.10")

def test_connectivity():
    logging.info("Testing internet connectivity...")
    os.system("ping -c 3 8.8.8.8 >> ue_ping.log 2>> ue_ping.err")

send_registration()
wait_for_ip()
test_connectivity()
