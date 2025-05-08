from flask import Flask, request, jsonify

app = Flask(__name__)

class UPF:
    def __init__(self):
        self.sessions = {}

    def configure(self, config):
        print("[UPF] Configuring user plane security")
        ue_id = config['ue_id']
        self.sessions[ue_id] = {
            "k_up_enc": config['k_up_enc'],
            "status": "active"
        }
        return {"status": "configured"}

upf = UPF()

@app.route('/configure', methods=['POST'])
def configure():
    data = request.json
    response = upf.configure(data)
    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5006)