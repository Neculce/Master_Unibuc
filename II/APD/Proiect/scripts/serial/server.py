import socket
import threading
import time

HOST = '0.0.0.0'
PORT = 5000
data_store = {}

def handle_client(conn, addr):
    client_id = addr 
    print(f"[+] Conectat: {client_id}")
    
    try:
        while True:
            data = conn.recv(1024)
            if not data:
                break
            try:
                val_str = data.decode('utf-8').strip()
                if val_str:
                    data_store[client_id] = float(val_str)
            except ValueError:
                pass
    except:
        pass
    finally:
        if client_id in data_store:
            del data_store[client_id]
        conn.close()

def monitor_loop():
    while True:
        time.sleep(2)
        if not data_store:
            print("[SERVER] Aștept date...", end='\r')
            continue
            
        vals = list(data_store.values())
        if vals:
            media = sum(vals) / len(vals)
            print(f"[CENTRAL] Noduri Active: {len(vals)} | Media Load: {media:.4f}")

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind((HOST, PORT))
server.listen()

print(f"[*] Server Centralizat Pornit pe {HOST}:{PORT}")

threading.Thread(target=monitor_loop, daemon=True).start()

while True:
    conn, addr = server.accept()
    threading.Thread(target=handle_client, args=(conn, addr), daemon=True).start()