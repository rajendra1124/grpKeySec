from flask import Flask, request, jsonify
import requests
import hashlib

app = Flask(__name__)

# Network function addresses
AUSF_ADDRESS = "http://ausf:5003"
SMF_ADDRESS = "http://smf:5005"
G_NB_ADDRESS = "http://gnb:5001"

class AMF:
    def __init__(self):
        self.ue_contexts = {}
        self.k_amf = None

    def handle_registration(self, registration_request):
        print("[AMF] Received Registration Request")
        ue_id = registration_request['ue_id']
        
        # Initiate authentication
        auth_request = {
            "ue_id": ue_id,
            "serving_network": "5G:mnc001.mcc001.3gppnetwork.org"
        }
        response = requests.post(f"{AUSF_ADDRESS}/authenticate", json=auth_request)
        
        # Store authentication context
        self.ue_contexts[ue_id] = response.json()
        self.k_amf = self.derive_k_amf(response.json()['k_ausf'])
        
        # Send Security Mode Command
        k_nas_enc = self.derive_key(self.k_amf, "NAS_ENC")
        k_nas_int = self.derive_key(self.k_amf, "NAS_INT")
        
        security_command = {
            "ue_id": ue_id,
            "command": "NAS Security Mode Command",
            "mac": self.calculate_mac({"command": "NAS Security Mode Command"}, k_nas_int)
        }
        requests.post(f"{G_NB_ADDRESS}/security_command", json=security_command)
        
        return {"status": "authentication_initiated"}

    def handle_security_complete(self, complete_message):
        print("[AMF] Received Security Mode Complete")
        ue_id = complete_message['ue_id']
        
        # Derive K_gNB
        k_gnb = self.derive_key(self.k_amf, "K_gNB")
        
        # Setup UE context in gNB
        ue_context = {
            "ue_id": ue_id,
            "k_gnb": k_gnb,
            "security_capabilities": ["5G-EA0", "5G-IA0"]
        }
        requests.post(f"{G_NB_ADDRESS}/ue_context_setup", json=ue_context)
        
        # Notify SMF
        smf_request = {
            "ue_id": ue_id,
            "k_gnb": k_gnb
        }
        requests.post(f"{SMF_ADDRESS}/session_establishment", json=smf_request)
        
        return {"status": "registration_complete"}

    def derive_k_amf(self, k_ausf):
        return f"K_AMF_derived_from_{k_ausf[:10]}"

    def derive_key(self, parent_key, key_name):
        return f"{key_name}_derived_from_{parent_key[:10]}"

    def calculate_mac(self, message, key):
        return f"MAC_{hashlib.sha256((str(message)+key).encode()).hexdigest()[:8]}"

amf = AMF()

@app.route('/registration', methods=['POST'])
def registration():
    data = request.json
    response = amf.handle_registration(data)
    return jsonify(response)

@app.route('/security_complete', methods=['POST'])
def security_complete():
    data = request.json
    response = amf.handle_security_complete(data)
    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)