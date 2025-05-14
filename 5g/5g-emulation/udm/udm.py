# udm.py
import socket, logging

logging.basicConfig(filename='udm.log', level=logging.DEBUG)

def serve():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.bind(('', 9003))
    while True:
        data, addr = s.recvfrom(1024)
        logging.info("Received profile request")
        s.sendto(b'USER_PROFILE_OK', addr)

serve()
