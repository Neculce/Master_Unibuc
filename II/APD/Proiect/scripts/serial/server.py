import socket
import threading
import time

HOST = '0.0.0.0'
PORT = 5000
data_store = {}

def handle_client(conn, addr):
    ip = addr[0]
    try:
        while True:
            data = conn.recv(1024)
            if not data:
                break
            try:
                data_store[ip] = float(data.decode('utf-8'))
            except ValueError:
                pass
    finally:
        data_store.pop(ip, None)
        conn.close()

def monitor_loop():
    while True:
        time.sleep(2)
        if not data_store:
            print("[SERVER] Aștept conexiuni...")
            continue
        vals = list(data_store.values())
        media = sum(vals) / len(vals)
        print(f"[CENTRAL] Noduri: {len(vals)} | Media load: {media:.2f}")

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind((HOST, PORT))
server.listen()
print(f"[*] Server pe {HOST}:{PORT}")

threading.Thread(target=monitor_loop, daemon=True).start()
while True:
    conn, addr = server.accept()
    threading.Thread(target=handle_client, args=(conn, addr)).start()
