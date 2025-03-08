#!/bin/bash

echo ">>> Удаление мониторинга Hive..."

# Пути
SCRIPT_PATH="/usr/local/bin/check_hive_logs.sh"
SERVICE_PATH="/etc/systemd/system/hive-monitor.service"
TIMER_PATH="/etc/systemd/system/hive-monitor.timer"
LOG_FILE="/var/log/hive_monitor.log"

# Остановка и отключение systemd сервисов
systemctl stop hive-monitor.timer
systemctl disable hive-monitor.timer
systemctl stop hive-monitor.service
systemctl disable hive-monitor.service

# Удаление файлов
rm -f $SCRIPT_PATH
rm -f $SERVICE_PATH
rm -f $TIMER_PATH
rm -f $LOG_FILE

# Перезагрузка systemd для удаления следов сервисов
systemctl daemon-reload

echo ">>> Мониторинг Hive удален!"
