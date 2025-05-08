from flask import Flask, request, jsonify
import threading
import time

app = Flask(__name__)

class UE:
    def __init__(self):
        self.registered = False
        self.ue_id = "imsi-001010000000001"
        
    def register(self):
        print(f"[UE {self.ue_id}] Starting registration procedure")
        # Add your actual registration logic here
        self.registered = True
        return {"status": "registration_started"}

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