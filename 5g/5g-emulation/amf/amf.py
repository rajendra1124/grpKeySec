# amf.py
import socket, logging

logging.basicConfig(filename='amf.log', level=logging.DEBUG)

def listen_gnb():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.bind(('', 9001))
    data, _ = s.recvfrom(1024)
    logging.info("Received NAS from gNB")
    return data

def auth_with_ausf():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.sendto(b'AUTH_REQ', ('192.168.0.3', 9002)) #ausf connections
    logging.info("Requested authentication")

def get_profile_from_udm():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.sendto(b'GET_PROFILE', ('192.168.0.4', 9003)) # udm connections
    logging.info("Requested profile")

def request_ip_from_upf():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.sendto(b'ALLOC_IP', ('192.168.0.5', 9004)) #upf
    logging.info("Requested IP from UPF")

def send_ip_to_ue():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.sendto(b'10.0.0.5', ('10.0.0.5', 8000)) #ue
    logging.info("Sent IP to UE")

listen_gnb()
auth_with_ausf()
get_profile_from_udm()
request_ip_from_upf()
send_ip_to_ue()
