from flask import Flask, request, jsonify
import requests
import os
import random


app = Flask(__name__)

UPF_ADDRESS = "http://upf:5006"

class SMF:
    def __init__(self):
        self.sessions = {}

    def establish_session(self, session_request):
        # Add GTP tunnel creation
        os.system("sudo ip link add gtp0 type gtp")
        os.system("sudo ip addr add 10.10.0.1/24 dev gtp0")
        os.system("sudo ip link set gtp0 up")
        
        print("[SMF] Establishing user plane session")
        ue_id = session_request['ue_id']
        k_gnb = session_request['k_gnb']
        
        # Derive UP key
        k_up_enc = self.derive_key(k_gnb, "UP_ENC")
        
        # Store session context
        self.sessions[ue_id] = {
            "k_up_enc": k_up_enc,
            "status": "active"
        }
        
        # Configure UPF
        upf_request = {
            "ue_id": ue_id,
            "k_up_enc": k_up_enc
        }
        requests.post(f"{UPF_ADDRESS}/configure", json=upf_request)
        
        # return {"status": "session_established"}
        # Configure UE IP address
        ue_ip = f"10.10.0.{random.randint(10,254)}"
        return {
            "status": "session_established",
            "ue_ip": ue_ip,
            "dns": "8.8.8.8"
            }
    def derive_key(self, parent_key, key_name):
        return f"{key_name}_derived_from_{parent_key[:10]}"

smf = SMF()

@app.route('/session_establishment', methods=['POST'])
def session_establishment():
    data = request.json
    response = smf.establish_session(data)
    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5005)