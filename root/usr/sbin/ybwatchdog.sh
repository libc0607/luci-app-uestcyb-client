#!/bin/sh

CLIENT=/usr/sbin/ybclient.lua

sleep 30

while true; do
        ping -c 5 -n -q www.baidu.com >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo "$(date): Connected."
        else
                echo "$(date): Not connected. Restart client..."
                $CLIENT $(uci get ybclient.client.username) $(uci get ybclient.client.password) $(uci get ybclient.client.type) login &
        fi
        sleep 10
done