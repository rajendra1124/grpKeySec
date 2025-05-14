from flask import Flask
import subprocess

app = Flask(__name__)

# def create_gtp_interface():
#     try:
#         # Load GTP kernel module
#         subprocess.run(["modprobe", "gtp"], check=True)
        
#         # Create GTP interface
#         subprocess.run([
#             "ip", "link", "add", "gtp0", "type", "gtp",
#             "role", "upf", "v1", "v2"
#         ], check=True)
        
#         # Assign IP address
#         subprocess.run([
#             "ip", "addr", "add", "10.10.0.2/24", "dev", "gtp0"
#         ], check=True)
        
#         # Bring interface up
#         subprocess.run(["ip", "link", "set", "gtp0", "up"], check=True)
        
#         return True
#     except subprocess.CalledProcessError as e:
#         print(f"GTP creation failed: {e}")
#         return False
def create_gtp_interface():
    try:
        subprocess.run(["modprobe", "gtp"], check=True)
        subprocess.run([
            "ip", "link", "add", "gtp0", "type", "gtp",
            "role", "upf"
        ], check=True)
        subprocess.run([
            "ip", "addr", "add", "10.10.0.1/24", "dev", "gtp0"
        ], check=True)
        subprocess.run(["ip", "link", "set", "gtp0", "up"], check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"GTP creation failed: {e}")
        return False

@app.route('/configure', methods=['POST'])
def configure():
    if not create_gtp_interface():
        return {"status": "GTP interface creation failed"}, 500
    
    # Configure NATs
    subprocess.run([
        "iptables", "-t", "nat", "-A", "POSTROUTING",
        "-o", "eth0", "-j", "MASQUERADE"
    ])
    
    return {
        "status": "UPF configured",
        "gtp_interface": "gtp0",
        "ue_gateway": "10.10.0.2",
        "subnet": "10.10.0.0/24"
    }

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5006)