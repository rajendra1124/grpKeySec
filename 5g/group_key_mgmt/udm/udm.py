from flask import Flask, request, jsonify
import hashlib

app = Flask(__name__)

# Mock subscriber database
SUBSCRIBER_DB = {
    "imsi-001010000000001": {
        "k": "0x00112233445566778899aabbccddeeff",
        "opc": "0x63bfa50ee6523365ff14c1f45f88737d",
        "sqn": 0
    }
}

class UDM:
    def __init__(self):
        pass

    def get_auth_data(self, ue_id):
        print("[UDM] Generating authentication vector")
        if ue_id not in SUBSCRIBER_DB:
            return {"status": "ue_not_found"}
        
        subscriber = SUBSCRIBER_DB[ue_id]
        
        # In real implementation, would generate RAND, AUTN, etc.
        # Simplified for demonstration
        return {
            "status": "success",
            "k_ausf": self.derive_k_ausf(subscriber['k']),
            "rand": "0x1234567890abcdef1234567890abcdef",
            "autn": "0xabcdef1234567890abcdef1234567890"
        }

    def derive_k_ausf(self, k):
        # Simplified key derivation
        return f"K_AUSF_derived_from_{k[:10]}"

udm = UDM()

@app.route('/auth_data', methods=['POST'])
def auth_data():
    data = request.json
    response = udm.get_auth_data(data['ue_id'])
    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5004)