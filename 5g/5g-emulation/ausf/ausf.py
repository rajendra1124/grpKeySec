# ausf.py
import socket, logging

logging.basicConfig(filename='ausf.log', level=logging.DEBUG)

def serve():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.bind(('', 9002))
    while True:
        data, addr = s.recvfrom(1024)
        logging.info("Received authentication request")
        s.sendto(b'AUTH_OK', addr)

serve()
