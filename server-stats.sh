#!/bin/bash 
#!/bin/bash
# server-stats.sh - lightweight server performance summary

echo "========================================"
echo "        SERVER PERFORMANCE STATS"
echo "========================================"

# OS Version
echo -e "\n--- OS Version ---"
if command -v lsb_release >/dev/null 2>&1; then
  lsb_release -a 2>/dev/null
else
  cat /etc/os-release 2>/dev/null || echo "OS info not found"
fi

# Uptime
echo -e "\n--- Uptime ---"
uptime -p 2>/dev/null || uptime

# Load Average
echo -e "\n--- Load Average ---"
uptime | awk -F'load average:' '{print $2}'

# Logged in Users
echo -e "\n--- Logged in Users ---"
who || echo "No active users"

# CPU Usage
echo -e "\n--- Total CPU Usage ---"
cpu_idle=$(top -bn1 2>/dev/null | grep -E "Cpu\\(s\\)|%Cpu" | awk '{print $8}' | cut -d',' -f1)
# fallback if parsing above fails (some systems differ)
if [ -z "$cpu_idle" ]; then
  cpu_idle=$(mpstat 1 1 2>/dev/null | awk '/all/ {print 100 - $NF}' | awk '{printf "%.1f", $0}')
  cpu_used="$cpu_idle"
else
  cpu_used=$(echo "100 - $cpu_idle" | bc 2>/dev/null)
fi
if [ -z "$cpu_used" ]; then
  echo "CPU usage: parsing not supported on this system"
else
  echo "${cpu_used}% used"
fi

# Memory Usage
echo -e "\n--- Memory Usage ---"
free -h

# Disk Usage
echo -e "\n--- Disk Usage ---"
df -h --total 2>/dev/null | grep -E "Filesystem|total" || df -h

# Top 5 processes by CPU
echo -e "\n--- Top 5 Processes by CPU Usage ---"
ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 6

# Top 5 processes by Memory
echo -e "\n--- Top 5 Processes by Memory Usage ---"
ps -eo pid,ppid,cmd,%mem --sort=-%mem | head -n 6

echo "========================================"
echo "           END OF REPORT"
echo "========================================"
