import sys

if len(sys.argv) != 2:
    print("Usage: python script.py <log_file>")
    sys.exit(1)

log_file = sys.argv[1]

user_agents = {}

try:
    with open(log_file, 'r') as file:
        for line in file:
            parts = line.split('"')
            if len(parts) > 5:
                user_agent = parts[-2].strip()
                if user_agent in user_agents:
                    user_agents[user_agent] += 1
                else:
                    user_agents[user_agent] = 1
except FileNotFoundError:
    print(f"Error: The file '{log_file}' was not found.")
    sys.exit(1)
except Exception as e:
    print(f"An error occurred: {e}")
    sys.exit(1)

for user_agent, count in user_agents.items():
    print(f"{user_agent}: {count} requests")
