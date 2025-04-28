import sys
import platform
import psutil
import requests

if len(sys.argv) < 2:
    print(f'Usage: python3 {sys.argv[0]} [-d] [-m] [-c] [-u] [-l] [-i]')
    sys.exit(1)

for arg in sys.argv[1:]:
    if arg == '-d':
        distribution_info = platform.platform()
        print("Distribution Info:", distribution_info)
        
    elif arg == '-m':
        mem = psutil.virtual_memory()
        print(f"Memory Info: Total: {mem.total} bytes, Used: {mem.used} bytes, Free: {mem.free} bytes")
        
    elif arg == '-c':
        cpu_model = platform.processor()
        cpu_cores = psutil.cpu_count(logical=False)
        cpu_speed = psutil.cpu_freq().current
        print(f"CPU Info: Model: {cpu_model}, Cores: {cpu_cores}, Speed: {cpu_speed} MHz")
        
    elif arg == '-u':
        current_user = platform.node()
        print("Current User:", current_user)
        
    elif arg == '-l':
        load_avg = psutil.getloadavg()
        print(f"Load Average: {load_avg}")
        
    elif arg == '-i':
        try:
            response = requests.get('https://api.ipify.org')
            ip_address = response.text
            print("External IP Address:", ip_address)
        except requests.RequestException as e:
            print("Could not retrieve external IP address:", e)
        
    else:
        print(f"Unknown argument: {arg}")