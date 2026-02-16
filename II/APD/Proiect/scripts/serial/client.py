import socket
import time
import os
import random

SERVER_IP = '127.0.0.1'
#SERVER_IP = '10.80.0.40'
SERVER_PORT = 5000

def get_load():
    try:
        base = os.getloadavg()[0]
        return base + random.uniform(-0.1, 0.1)
    except:
        return random.uniform(0.5, 2.0)

def start_agent():
    while True:
        try:
            client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            client.settimeout(5)
            client.connect((SERVER_IP, SERVER_PORT))
            print(f"[+] Conectat la {SERVER_IP}")
            
            while True:
                load = get_load()
                client.send(f"{load:.4f}".encode('utf-8'))
                time.sleep(2)
                
        except Exception as e:
            print(f"[!] Reîncerc conectarea... ({e})")
            time.sleep(3)

if __name__ == "__main__":
    start_agent()