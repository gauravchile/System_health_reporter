#  Scheduled System Health Reporter

A cron-based Bash project to monitor Linux system health and generate hourly logs.

##  Features
- Disk usage
- CPU load averages
- Memory usage
- Top 5 processes (by CPU)
- Auto-saves logs to `/var/log/system_health/`

##  Project Structure
System_Health_Reporter/
 system_health_reporter.sh # Main script
 sample_output.log # Example of report
 README.md # Documentation

##  Setup
```bash
Make script executable:

chmod +x system_health_reporter.sh
./system_health_reporter.sh --report (manually)
./system_health_reporter.sh --install (install hourly cron)

🔧 How to Use Notifications
Enable Email
Install mail utils:
sudo apt install -y mailutils

Enable Slack
Create a Slack Incoming Webhook (guide)
Replace the placeholder in script:
