#!/bin/bash
# ============================================
# Scheduled System Health Reporter
# Author: Gaurav Chile
# ============================================

LOG_DIR="/var/log/system_health"
mkdir -p "$LOG_DIR"

SCRIPT_PATH="$(realpath $0)"

# ====== CONFIG ======
EMAIL_ENABLED=true
EMAIL_TO="admin@example.com"

SLACK_ENABLED=true
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/XXXX/YYYY/ZZZZ"
# ====================

report() {
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    OUTPUT_FILE="$LOG_DIR/health_$TIMESTAMP.log"

    {
        echo "===== System Health Report: $(date) ====="

        echo -e "\n--- Disk Usage ---"
        df -h

        echo -e "\n--- CPU Load ---"
        uptime

        echo -e "\n--- Memory Usage ---"
        free -h

        echo -e "\n--- Top 5 Processes (CPU) ---"
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6

        echo -e "\n===== End of Report ====="
    } > "$OUTPUT_FILE"

    echo "✅ Report saved: $OUTPUT_FILE"

    # --- Email Notification ---
    if [ "$EMAIL_ENABLED" = true ]; then
        if command -v mail >/dev/null 2>&1; then
            cat "$OUTPUT_FILE" | mail -s "System Health Report $(date)" "$EMAIL_TO"
            echo "📧 Report emailed to $EMAIL_TO"
        else
            echo "⚠️ 'mail' command not found, skipping email."
        fi
    fi

    # --- Slack Notification ---
    if [ "$SLACK_ENABLED" = true ]; then
        if command -v curl >/dev/null 2>&1; then
            MESSAGE="*System Health Report* - $(date)\n\`\`\`$(tail -n 20 "$OUTPUT_FILE")\`\`\`"
            curl -s -X POST -H 'Content-type: application/json' \
                --data "{\"text\":\"$MESSAGE\"}" \
                "$SLACK_WEBHOOK_URL"
            echo "💬 Report sent to Slack"
        else
            echo "⚠️ 'curl' not found, skipping Slack notification."
        fi
    fi
}

install_cron() {
    crontab -l 2>/dev/null | grep -q "$SCRIPT_PATH --report"
    if [ $? -eq 0 ]; then
        echo "✅ Cron job already exists."
    else
        (crontab -l 2>/dev/null; echo "0 * * * * $SCRIPT_PATH --report") | crontab -
        echo "✅ Cron job installed: Runs every hour."
    fi
}

case "$1" in
    --report)
        report
        ;;
    --install)
        install_cron
        ;;
    *)
        echo "Usage: $0 [--report | --install]"
        ;;
esac
