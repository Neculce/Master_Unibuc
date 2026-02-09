import socket
import time
import os

SERVER_IP = '127.0.0.1'
SERVER_PORT = 5000

def get_load():
    try:
        return os.getloadavg()[0] 
    except OSError:
        return 0.0

def start_agent():
    print(f"[*] Agent -> {SERVER_IP}:{SERVER_PORT}")
    while True:
        try:
            client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            client.settimeout(5)
            client.connect((SERVER_IP, SERVER_PORT))
            print("[+] Conectat.")
            while True:
                load = get_load()
                client.send(str(load).encode('utf-8'))
                print(f"[SENT] load: {load:.2f}")
                time.sleep(2)
        except (ConnectionRefusedError, socket.timeout):
            print("[!] Server indisponibil, reîncerc în 3s...")
            time.sleep(3)
        except (BrokenPipeError, ConnectionResetError):
            client.close()
            time.sleep(1)

if __name__ == "__main__":
    start_agent()
