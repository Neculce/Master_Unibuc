import socket
import threading
import time
import random
import sys

MY_PORT = int(sys.argv[1])
TOPOLOGY = sys.argv[2]
N = int(sys.argv[3])
my_value = float(sys.argv[4])
lock = threading.Lock()

ALL_PORTS = range(5000, 5000 + N)
PEERS = []

if TOPOLOGY == "MESH":
    PEERS = [p for p in ALL_PORTS if p != MY_PORT]
elif TOPOLOGY == "RING":
    idx = MY_PORT - 5000
    left  = 5000 + (idx - 1) % N
    right = 5000 + (idx + 1) % N
    PEERS = list(set([left, right]))
    if MY_PORT in PEERS: PEERS.remove(MY_PORT)
elif TOPOLOGY == "STAR":
    HUB = 5000
    PEERS = [p for p in ALL_PORTS if p != HUB] if MY_PORT == HUB else [HUB]

def active():
    global my_value
    while True:
        time.sleep(random.uniform(0.1, 0.3))
        if not PEERS: continue
        
        target = random.choice(PEERS)
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.settimeout(0.5)
                s.connect(('127.0.0.1', target))
                s.send(f"{my_value}".encode())
                data = s.recv(1024)
                if data:
                    other_val = float(data)
                    with lock:
                        my_value = (my_value + other_val) / 2
        except: pass

        try:
            udp = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            udp.sendto(f"{MY_PORT}:{my_value}".encode(), ('127.0.0.1', 9999))
        except: pass

def passive():
    global my_value
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try: s.bind(('127.0.0.1', MY_PORT))
        except: return
        s.listen(5)
        
        while True:
            try:
                conn, _ = s.accept()
                conn.settimeout(0.5)
                with conn:
                    data = conn.recv(1024)
                    if data:
                        other_val = float(data)
                        conn.send(f"{my_value}".encode())
                        with lock:
                            my_value = (my_value + other_val) / 2
            except: pass

t1 = threading.Thread(target=active, daemon=True)
t2 = threading.Thread(target=passive, daemon=True)
t1.start()
t2.start()

while True: time.sleep(1)