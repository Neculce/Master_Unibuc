import socket
import threading
import time
import random
import os

NODES = ["10.80.0.10", "10.80.0.11", "10.80.0.30", "10.80.0.40"]
PORT = 5005
TOPO = "MESH" 
HUB = "10.80.0.10"

def get_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except: return "127.0.0.1"

MY_IP = get_ip()
PEERS = []

if TOPO == "MESH":
    PEERS = [ip for ip in NODES if ip != MY_IP]
elif TOPO == "RING":
    srt = sorted(NODES)
    if MY_IP in srt:
        i, n = srt.index(MY_IP), len(srt)
        PEERS = [srt[(i-1)%n], srt[(i+1)%n]]
        if MY_IP in PEERS: PEERS.remove(MY_IP)
elif TOPO == "STAR":
    PEERS = [ip for ip in NODES if ip != MY_IP] if MY_IP == HUB else [HUB]

state = {'avg': 0.0, 'load': 0.0}
lock = threading.Lock()

def active():
    last = 0.0
    while True:
        curr = os.getloadavg()[0]
        with lock:
            state['avg'] += (curr - last)
            state['load'] = curr
            last = curr
            my_val = state['avg']
        
        print(f"Load: {state['load']:.2f} | Avg: {state['avg']:.4f}")
        
        if PEERS:
            try:
                s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                s.settimeout(0.5)
                s.connect((random.choice(PEERS), PORT))
                s.send(str(my_val).encode())
                data = s.recv(1024)
                if data:
                    with lock: state['avg'] = (state['avg'] + float(data)) / 2
                s.close()
            except: pass
        time.sleep(1)

def passive():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(('0.0.0.0', PORT))
    s.listen(10)
    while True:
        try:
            c, _ = s.accept()
            c.settimeout(1)
            data = c.recv(1024)
            if data:
                inc = float(data)
                with lock:
                    reply = state['avg']
                    state['avg'] = (state['avg'] + inc) / 2
                c.send(str(reply).encode())
            c.close()
        except: pass

if __name__ == '__main__':
    threading.Thread(target=active, daemon=True).start()
    threading.Thread(target=passive, daemon=True).start()
    while True: time.sleep(1)