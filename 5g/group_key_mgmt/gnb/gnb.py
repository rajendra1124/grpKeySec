from flask import Flask, request, jsonify
import requests
import threading

app = Flask(__name__)

# Network function addresses
AMF_ADDRESS = "http://amf:5002"
UE_ADDRESS = "http://ue:5000"

class GNB:
    def __init__(self):
        self.ue_contexts = {}
        self.k_gnb = None

    def handle_registration(self, registration_request):
        print("[gNB] Received Registration Request from UE")
        # Forward to AMF
        response = requests.post(f"{AMF_ADDRESS}/registration", json=registration_request)
        return response.json()

    def handle_ue_context_setup(self, context):
        print("[gNB] Received UE Context Setup from AMF")
        ue_id = context['ue_id']
        self.ue_contexts[ue_id] = context
        self.k_gnb = context['k_gnb']
        
        # Derive RRC keys
        k_rrc_enc = self.derive_key(self.k_gnb, "RRC_ENC")
        k_rrc_int = self.derive_key(self.k_gnb, "RRC_INT")
        
        # Send Security Mode Command to UE
        security_command = {
            "ue_id": ue_id,
            "command": "RRC Security Mode Command",
            "mac": self.calculate_mac({"command": "RRC Security Mode Command"}, k_rrc_int)
        }
        requests.post(f"{UE_ADDRESS}/security_command", json=security_command)
        print("[gNB] Sent RRC Security Mode Command to UE")

    def derive_key(self, parent_key, key_name):
        return f"{key_name}_derived_from_{parent_key[:10]}"

    def calculate_mac(self, message, key):
        return f"MAC_{hash(str(message)+key)[:8]}"

gnb = GNB()

@app.route('/registration', methods=['POST'])
def registration():
    data = request.json
    response = gnb.handle_registration(data)
    return jsonify(response)

@app.route('/ue_context_setup', methods=['POST'])
def ue_context_setup():
    data = request.json
    gnb.handle_ue_context_setup(data)
    return jsonify({"status": "success"})

@app.route('/security_complete', methods=['POST'])
def security_complete():
    data = request.json
    print("[gNB] Received Security Mode Complete from UE")
    # Forward to AMF
    requests.post(f"{AMF_ADDRESS}/security_complete", json=data)
    return jsonify({"status": "success"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)