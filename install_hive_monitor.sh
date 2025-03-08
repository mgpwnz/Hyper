#!/bin/bash

echo ">>> Установка мониторинга Hive..."

# Пути
SCRIPT_PATH="/usr/local/bin/check_hive_logs.sh"
SERVICE_PATH="/etc/systemd/system/hive-monitor.service"
TIMER_PATH="/etc/systemd/system/hive-monitor.timer"
LOG_FILE="/var/log/hive_monitor.log"

# Создание скрипта мониторинга
cat <<EOF > $SCRIPT_PATH
#!/bin/bash

LOG_DIR="/root/.cache/hyperspace/kernel-logs"
LOG_FILE=\$(ls -t "\$LOG_DIR" | head -n 1)
LOG_PATH="\$LOG_DIR/\$LOG_FILE"

CHECK_PATTERN="Last pong received at"
DISCONNECT_CMD="aios-cli hive disconnect"
CONNECT_CMD="aios-cli hive connect"

# Проверяем, есть ли зависания
if tail -n 100 "\$LOG_PATH" | grep -q "\$CHECK_PATTERN"; then
    echo "\$(date) - Обнаружено зависание, выполняем перезапуск узла..." >> $LOG_FILE
    \$DISCONNECT_CMD
    sleep 30
    \$CONNECT_CMD
    echo "\$(date) - Узел переподключен." >> $LOG_FILE
else
    echo "\$(date) - Узел работает стабильно." >> $LOG_FILE
fi
EOF

# Устанавливаем права на выполнение
chmod +x $SCRIPT_PATH

echo ">>> Скрипт мониторинга создан."

# Создание systemd service
cat <<EOF > $SERVICE_PATH
[Unit]
Description=Мониторинг логов Hive
After=network.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH
StandardOutput=append:$LOG_FILE
StandardError=append:$LOG_FILE

[Install]
WantedBy=multi-user.target
EOF

echo ">>> Сервис systemd создан."

# Создание systemd timer
cat <<EOF > $TIMER_PATH
[Unit]
Description=Запуск мониторинга Hive каждые 5 минут

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Unit=hive-monitor.service

[Install]
WantedBy=timers.target
EOF

echo ">>> Таймер systemd создан."

# Перезагружаем systemd и включаем сервисы
systemctl daemon-reload
systemctl enable hive-monitor.service
systemctl enable hive-monitor.timer
systemctl start hive-monitor.timer

echo ">>> Мониторинг Hive установлен и запущен!"
