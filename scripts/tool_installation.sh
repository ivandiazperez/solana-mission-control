#!/bin/bash

set -e

cd $HOME

echo "--------- Cloning solana-monitoring-tool -----------"

git clone https://github.com/Chainflow/solana-mission-control.git

cd solana-mission-control

mkdir -p  ~/.solana-mc/config/

cp example.config.toml ~/.solana-mc/config/config.toml

cd $HOME

echo "------ Updatig config fields with exported values -------"

sed -i '/rpc_endpoint =/c\rpc_endpoint = "'"$RPC_ENDPOINT"'"' ~/.solana-mc/config/config.toml

sed -i '/network_rpc =/c\network_rpc = "'"$NETWORK_RPC"'"' ~/.solana-mc/config/config.toml

sed -i '/validator_name =/c\validator_name = "'"$VALIDATOR_NAME"'"'  ~/.solana-mc/config/config.toml

sed -i '/pub_key =/c\pub_key = "'"$PUB_KEY"'"'  ~/.solana-mc/config/config.toml

sed -i '/vote_key =/c\vote_key = "'"$VOTE_KEY"'"'  ~/.solana-mc/config/config.toml

if [ ! -z "${TELEGRAM_CHAT_ID}" ] && [ ! -z "${TELEGRAM_BOT_TOKEN}" ];
then 
    sed -i '/tg_chat_id =/c\tg_chat_id = '"$TELEGRAM_CHAT_ID"''  ~/.solana-mc/config/config.toml

    sed -i '/tg_bot_token =/c\tg_bot_token = "'"$TELEGRAM_BOT_TOKEN"'"'  ~/.solana-mc/config/config.toml

    sed -i '/enable_telegram_alerts =/c\enable_telegram_alerts = 'true''  ~/.solana-mc/config/config.toml
else
    echo "---- Telgram chat id and/or bot token are empty --------"
fi

echo "------ Building and running the code --------"

cd $HOME
cd solana-mission-control

go build -o solana-mc
mv solana-mc $HOME/go/bin/

echo "--------checking for solana binary path and updates it in env--------"

if [ ! -z "${SOLANA_BINARY_PATH}" ];
then 
    SOLANA_BINARY="$SOLANA_BINARY_PATH"
else 
    SOLANA_BINARY="solana"
fi

echo "----------- Setup solana-mc service------------"

echo "[Unit]
Description=Solana-mc
After=network-online.target

[Service]
User=$USER
Environment="SOLANA_BINARY_PATH=$SOLANA_BINARY"
ExecStart=$HOME/go/bin/solana-mc
Restart=always
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target" | sudo tee "/lib/systemd/system/solana_mc.service"

echo "--------------- Start Solana-Mession-Control service ----------------"


sudo systemctl daemon-reload

sudo systemctl enable solana_mc.service

sudo systemctl start solana_mc.service

echo "** Done **"
