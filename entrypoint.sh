#!/usr/bin/env bash

UUID=${UUID:-'de04add9-5c68-8bab-950c-08cd5320df18'}
VMESS_WSPATH=${VMESS_WSPATH:-'/vmess'}
VLESS_WSPATH=${VLESS_WSPATH:-'/vless'}

sed -i "s#UUID#$UUID#g;s#VMESS_WSPATH#${VMESS_WSPATH}#g;s#VLESS_WSPATH#${VLESS_WSPATH}#g" config.json
sed -i "s#VMESS_WSPATH#${VMESS_WSPATH}#g;s#VLESS_WSPATH#${VLESS_WSPATH}#g" /etc/nginx/nginx.conf

if [ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_PORT}" ] && [ -n "${NEZHA_KEY}" ]; then
    echo "[Info] Initializing Nezha Agent..."
    wget -qO nezha-agent.zip "https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_linux_amd64.zip"
    unzip -q nezha-agent.zip -d nezha_tmp
    # 使用 find 动态定位二进制文件，消除路径强依赖风险
    NEZHA_BIN=$(find nezha_tmp -type f -name "nezha-agent" | head -n 1)
    mv "$NEZHA_BIN" ./nezha-agent
    chmod +x nezha-agent
    rm -rf nezha-agent.zip nezha_tmp
    
    TLS_ARG=${NEZHA_TLS:+'--tls'}
    ./nezha-agent -s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} ${TLS_ARG} &
    echo "[Info] Nezha Agent started."
fi

echo "[Info] Starting Nginx..."
nginx -g 'daemon off;' &

echo "[Info] Starting V2Ray Core..."
./v2ray run -c config.json &

wait -n

echo "[Fatal] A core component crashed! Triggering container restart gracefully..."
exit 1