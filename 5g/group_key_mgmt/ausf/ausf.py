from flask import Flask, request, jsonify
import requests
import hashlib

app = Flask(__name__)

UDM_ADDRESS = "http://udm:5004"

class AUSF:
    def __init__(self):
        self.authentication_vectors = {}

    def authenticate(self, auth_request):
        print("[AUSF] Received Authentication Request")
        ue_id = auth_request['ue_id']
        
        # Get authentication vector from UDM
        response = requests.post(f"{UDM_ADDRESS}/auth_data", json={"ue_id": ue_id})
        auth_vector = response.json()
        
        # Store K_AUSF
        self.authentication_vectors[ue_id] = auth_vector
        
        return {
            "status": "success",
            "k_ausf": auth_vector['k_ausf'],
            "auth_result": "authenticated"
        }

ausf = AUSF()

@app.route('/authenticate', methods=['POST'])
def authenticate():
    data = request.json
    response = ausf.authenticate(data)
    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003)