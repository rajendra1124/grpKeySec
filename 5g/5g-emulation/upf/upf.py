# upf.py
import socket, logging, os

logging.basicConfig(filename='upf.log', level=logging.DEBUG)

def serve():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.bind(('', 9004))
    while True:
        data, addr = s.recvfrom(1024)
        if data == b'ALLOC_IP':
            logging.info("Allocating IP to UE")
            # Setup NAT for internet access
            os.system("iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE")
            s.sendto(b'IP_ALLOC_OK', addr)

serve()
