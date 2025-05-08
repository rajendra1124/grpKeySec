from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

UPF_ADDRESS = "http://upf:5006"

class SMF:
    def __init__(self):
        self.sessions = {}

    def establish_session(self, session_request):
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
        
        return {"status": "session_established"}

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