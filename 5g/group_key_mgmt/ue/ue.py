from flask import Flask, request, jsonify
import threading
import time
import subprocess

app = Flask(__name__)

class UE:
    def __init__(self):
        self.registered = False
        self.ue_id = "imsi-001010000000001"
        self.ip_address = None
        self.default_gateway = "10.10.0.2"  # UPF's GTP interface
        
    def register(self):
        print(f"[UE {self.ue_id}] Starting registration procedure")
        # Add your actual registration logic here
        self.registered = True
        return {"status": "registration_started"}

    def configure_network(self, session_info):
        self.ip_address = session_info['ue_ip']
        
        # Configure UE network interface
        subprocess.run(f"sudo ip addr add {self.ip_address}/24 dev eth0", shell=True)
        subprocess.run(f"sudo ip route add default via {self.default_gateway}", shell=True)
        
    # def test_internet(self):
    #     return subprocess.run("ping -c 4 8.8.8.8", shell=True, capture_output=True)
ue = UE()

@app.route('/register', methods=['POST'])
def handle_register():
    return jsonify(ue.register())

@app.route('/health')
def health():
    return "UE OK", 200

def run_server():
    app.run(host='0.0.0.0', port=5000, debug=False, use_reloader=False)

if __name__ == '__main__':
    print("Starting UE server...")
    run_server()