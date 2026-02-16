import subprocess
import time

N = 50
for i in range(N):
    subprocess.Popen(['python3', 'client.py'])
    time.sleep(0.1)
print(f"Lansat {N} clienți seriali.")