#!/bin/bash
# =====================================
# Scheduled System Health Reporter
# Author: Gaurav Chile
# =====================================

OUTPUT_DIR="/var/log/system_health"
SCRIPT_PATH="$(realpath $0)"

# Create log directory
mkdir -p "$OUTPUT_DIR"

# Function: Generate report
generate_report() {
    OUTPUT_FILE="$OUTPUT_DIR/health_$(date +%F_%H-%M-%S).log"

    {
    echo "===== System Health Report: $(date) ====="

    # Disk usage
    echo -e "\n--- Disk Usage ---"
    df -h --output=source,size,used,avail,pcent,target | column -t

    # CPU load
    echo -e "\n--- CPU Load (1/5/15 min) ---"
    uptime | awk -F'load average: ' '{print $2}'

    # Memory usage
    echo -e "\n--- Memory Usage ---"
    free -h

    # Top 5 CPU-consuming processes
    echo -e "\n--- Top 5 CPU Processes ---"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6

    # Top 5 Memory-consuming processes
    echo -e "\n--- Top 5 Memory Processes ---"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6

    echo -e "\n===== End of Report ====="

    } >> "$OUTPUT_FILE"

    echo " Report generated: $OUTPUT_FILE"
}

# Function: Install cron job
install_cron() {
    echo "  Installing cron job to run every hour..."
    # Check if cron job already exists
    (crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH" ; echo "0 * * * * $SCRIPT_PATH --report") | crontab -
    echo " Cron job installed."
}

# Main logic
if [[ "$1" == "--report" ]]; then
    generate_report
elif [[ "$1" == "--install" ]]; then
    install_cron
else
    echo "Usage:"
    echo "  $0 --report    # Generate report now"
    echo "  $0 --install   # Install cron job (hourly)"
fi

