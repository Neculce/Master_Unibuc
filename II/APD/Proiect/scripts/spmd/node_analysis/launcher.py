import subprocess
import time
import socket
import threading
import sys
import random
import heapq
import matplotlib.pyplot as plt

try: plt.style.use('seaborn-v0_8-darkgrid')
except: plt.style.use('ggplot')

N = 50
TOPOLOGY = "MESH"
KILL_ENABLE = False
TOTAL_SUM_GOAL = 1000.0 

if len(sys.argv) > 1: TOPOLOGY = sys.argv[1]
if len(sys.argv) > 2: N = int(sys.argv[2])
if "--kill" in sys.argv: KILL_ENABLE = True

raw_randoms = [random.expovariate(1.5) for _ in range(N)]
sum_raw = sum(raw_randoms)
start_values = [(r / sum_raw) * TOTAL_SUM_GOAL for r in raw_randoms]
TARGET_MEAN = TOTAL_SUM_GOAL / N

print(f"START: {N} Noduri | Topo: {TOPOLOGY} | Tinta: {TARGET_MEAN:.4f}")

history_time = []
history_error = []
history_avg = []
node_values = {}
running = True
start_time = time.time()
kill_marker = None

def cleanup():
    subprocess.call(['pkill', '-f', 'node.py'])

def monitor():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('127.0.0.1', 9999))
    sock.settimeout(1.0)
    while running:
        try:
            data, _ = sock.recvfrom(1024)
            port, val = data.decode().split(':')
            node_values[int(port)] = float(val)
        except: continue

threading.Thread(target=monitor, daemon=True).start()

cleanup()
for i in range(N):
    port = 5000 + i
    val = start_values[i] 
    cmd = ['python3', 'node.py', str(port), TOPOLOGY, str(N), str(val)]
    subprocess.Popen(cmd)
    if i % 10 == 0: time.sleep(0.1)

if KILL_ENABLE:
    def killer():
        time.sleep(1.0)
        
        if len(node_values) > 2:
            richest_ports = heapq.nlargest(3, node_values, key=node_values.get)
            target_port = random.choice(richest_ports)
            print(f"\nKILL: Nod {target_port} (Valoare: {node_values[target_port]:.2f})")
        else:
            target_port = random.randint(5000, 5000 + N - 1)
            print(f"\nKILL RANDOM: {target_port}")

        subprocess.call(['pkill', '-f', f'node.py {target_port}'])
        
        global kill_marker
        kill_marker = time.time() - start_time
        if target_port in node_values: del node_values[target_port]

    threading.Thread(target=killer, daemon=True).start()

try:
    while True:
        time.sleep(0.5)
        elapsed = time.time() - start_time
        vals = list(node_values.values())
        
        if len(vals) < N * 0.8: 
            print(f"Conectare... {len(vals)}/{N}", end='\r')
            continue
            
        curr_avg = sum(vals) / len(vals)
        error = max(vals) - min(vals)
        
        history_time.append(elapsed)
        history_error.append(error)
        history_avg.append(curr_avg)
        
        print(f"T: {elapsed:.1f}s | Avg: {curr_avg:.4f} | Err: {error:.4f}", end='\r')
        
        if error < 0.01 and elapsed > 5:
            print(f"\nCONSENS: {curr_avg:.4f}")
            break

except KeyboardInterrupt:
    print("\nStop.")

finally:
    running = False
    cleanup()
    
    plt.figure(figsize=(10, 8))
    
    plt.subplot(2, 1, 1)
    plt.plot(history_time, history_error, 'r-', label='Eroare')
    if kill_marker: 
        plt.axvline(x=kill_marker, color='k', linestyle='--', label='KILL')
    plt.title(f'{TOPOLOGY} N={N}')
    plt.ylabel('Eroare')
    plt.legend()
    plt.grid(True)
    
    plt.subplot(2, 1, 2)
    plt.plot(history_time, history_avg, 'b-', label='Medie')
    plt.axhline(y=TARGET_MEAN, color='g', linestyle='--', linewidth=2, label='Tinta')
    if kill_marker: plt.axvline(x=kill_marker, color='k', linestyle='--')
    plt.ylabel('Medie')
    plt.xlabel('Timp')
    plt.legend()
    plt.grid(True)
    
    filename = f"grafic_{TOPOLOGY}.png"
    plt.savefig(filename)
    print(f"Grafic: {filename}")