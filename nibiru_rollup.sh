#!/bin/bash

# Download Nibiru Cosmos SDK repo
cd $HOME
rm -rf nibiru
git clone https://github.com/NibiruChain/nibiru.git
cd $HOME/nibiru
git checkout v0.19.2

if [ -f "$(which nibid)" ] ; then 
	rm -rf $(which nibid); 
	rm -rf $HOME/.nibid
fi

# ======= Select Cosmos SDK rollkit version ======
# Check Cosmos SDK verison using by chain
CUR_SDK_VER=$(cat go.mod | grep "github.com/cosmos/cosmos-sdk " | awk '{print $2}')
echo -e "\n\e[42mCurrent Cosmos SDK version using by your chain: $CUR_SDK_VER \e[0m"

# Check existing released version of Cosmos-SDK rollkit which is consistent to Cosmos-SDK chain
echo -e "\n\033[0;32mBelow is available Cosmos SDK Rollkit version consistent with your chain.\033[0m\n"

no=1;
latest_ver="";

for i in `curl -s https://github.com/rollkit/cosmos-sdk/tags/ | grep -e "/rollkit/cosmos-sdk/releases/tag/" | awk '{print $NF}' | grep class | sed -e "s/>/\|/g;s/</\|/g" | awk -F"|" '{print $2}' | sort -u | grep rollkit | grep $(echo $CUR_SDK_VER | awk -F"\." '{print $1"."$2}')`; do
	echo "${no}. $i"
	no=`expr $no + 1`;
	latest_ver=$i;
done

echo -e "\nKindly select version (default is latest version \033[0;32m$latest_ver\033[0m):" 
read SEL_SDK_VER  # Selected Rollkit SDK version

if [[ $SEL_SDK_VER == "" ]]
then 
	SEL_SDK_VER=$latest_ver;
	echo -e "You did not select, so version will be latest one \033[0;32m$latest_ver\033[0m"
else 
	url="https://github.com/rollkit/cosmos-sdk/releases/tag/${SEL_SDK_VER}"
	status=$(curl --head --silent ${url} | head -n 1) # check status of link
	if echo "$status" | grep -q 404 ; then
  		echo -e "\nYour selected version \033[0;31m${SEL_SDK_VER}\033[0m is not exist. Please rerun script.\n";
		exit
	fi 
fi

# ====== Select Rollkit Tendermint version ======
# Check Terdenmint verison using by chain
CUR_TEND_VER=$(cat go.mod | grep "github.com/tendermint/tendermint " | awk '{print $2}')
echo -e "\n\e[42mCurrent Tendermint version using by your chain: $CUR_TEND_VER \e[0m"

# Check existing released version of Tendermint Rollkit which is consistent to Tendermint
echo -e "\n\033[0;32mBelow is available Tendermint Rollkit version consistent with your chain.\033[0m\n"

no=1;
latest_ver="";

for i in `curl -s https://github.com/rollkit/tendermint/tags/ | grep -e "/rollkit/tendermint/releases/tag/" | sed -s "s/.*primary\">\(.*\)<\/a.*/\1/g" | sort -u | grep $(echo $CUR_TEND_VER | awk -F"\." '{print $1"."$2}')`; do
        echo "${no}. $i"
        no=`expr $no + 1`;
        latest_ver=$i;
done

echo -e "\nKindly select version (default is latest version \033[0;32m$latest_ver\033[0m):"
read SEL_TEND_VER  # Selected Rollkit Tendermint version

if [[ $SEL_TEND_VER == "" ]]
then
        SEL_TEND_VER=$latest_ver;
        echo -e "You did not select, so version will be latest one \033[0;32m$latest_ver\033[0m"
else
        url="https://github.com/rollkit/tendermint/releases/tag/${SEL_TEND_VER}"
        status=$(curl --head --silent ${url} | head -n 1) # check status of link
        if echo "$status" | grep -q 404 ; then
                echo -e "\nYour selected version \033[0;31m${SEL_TEND_VER}\033[0m is not exist. Please rerun script.\n";
                exit
        fi
fi

# ===== Convert your Cosmos SDK L1 chain to be Cosmos SDK rollup =====
echo -e "\n\033[0;32mStart to convert your chain to be Rollup...\033[0m\n"; sleep 1;
# echo -e "\nConvert Cosmos-SDK \033[0;31m$CUR_SDK_VER\033[0m to Rollkit Cosmos-SDK \033[0;31m$SEL_SDK_VER\033[0m"; sleep 2;
go mod edit -replace github.com/cosmos/cosmos-sdk=github.com/rollkit/cosmos-sdk@$SEL_SDK_VER
# echo -e "\nConvert Tendermint \033[0;31m$CUR_TEND_VER\033[0m to Rollkit Tendermint \033[0;31m$SEL_TEND_VER\033[0m"; sleep 2;
go mod edit -replace github.com/tendermint/tendermint=github.com/celestiaorg/tendermint@v0.34.22-0.20221202214355-3605c597500d
# go mod edit -replace github.com/tendermint/tendermint=github.com/celestiaorg/tendermint@$SEL_TEND_VER;
go mod tidy
go mod download
make install;

# Exit script if compiling binary get error
if [ $? -ne 0 ]; then
  echo -e "\n\033[0;31mWarning: Compiling got error !!!\033[0m\n" 
  exit 1
fi

echo -e "\n\033[0;32mCompiling binary file is finished !! \033[0m\n"; sleep 1;

# ===== Setting Rollup local devnet =====
echo -e "\n\033[0;32mSetting up your Rollup devnet chain on Celestia Blockspacerace DA layer. Please wait.....  \033[0m\n"; sleep 1;
# Setup some variables
# cd $HOME
echo -e "\n\033[0;32mSetup some variable\033[0m"; sleep 1;
VALIDATOR_NAME=nibi-seq-1
CHAIN_ID=nibi-rollup-local
CHAINFLAG="--chain-id ${CHAIN_ID}"
TOKEN_AMOUNT="10000000000000000000000000unibi"
STAKING_AMOUNT="1000000000unibi"
DENOM="unibi"

echo -e "
- Sequencer name: \033[0;31m${VALIDATOR_NAME}\033[0m
- Chain id : \033[0;31m${CHAIN_ID}\033[0m
- Denom: \033[0;31m${DENOM}\033[0m
"

rm -rf $HOME/.nibid

# initialize the validator with the chain ID you set
echo -e "\n\033[0;32mInitialise your chain \033[0m\n"; sleep 1;
nibid init $VALIDATOR_NAME --chain-id $CHAIN_ID

# add keys for key 1 and key 2 to keyring-backend test
echo -e "\nKindly create your wallet:"
read -p "Your 1st wallet name: " KEY_NAME
read -p "Seedphrase of 1st wallet (press Enter if new one): " KEY_NAME_SEED

echo -e "\n"
read -p "Your 2nd wallet name: " KEY_2_NAME
read -p "Seedphrase of 2nd wallet (press Enter if new one): " KEY_2_NAME_SEED


if [[ (-n $KEY_NAME_SEED) || (-n $KEY_2_NAME_SEED) ]]; then 
	RECOVER="--recover "
fi 

echo "$KEY_NAME_SEED" | nibid keys add $KEY_NAME --keyring-backend test $RECOVER
echo "$KEY_2_NAME_SEED" | nibid keys add $KEY_2_NAME --keyring-backend test $RECOVER
echo -e "\n\033[0;32mCreated your wallet ! \033[0m\n" ; sleep 2;

sed -i.bak -e "s|\"stake\"|\"$DENOM\"|g" $HOME/.nibid/config/genesis.json

# add these as genesis accounts
nibid add-genesis-account $KEY_NAME $TOKEN_AMOUNT --keyring-backend test
nibid add-genesis-account $KEY_2_NAME $TOKEN_AMOUNT --keyring-backend test

# set the staking amounts in the genesis transaction
nibid gentx $KEY_NAME $STAKING_AMOUNT --chain-id $CHAIN_ID --keyring-backend test

# collect genesis transactions
nibid collect-gentxs

# Fill in IP and port of DA node
echo -e "\nPlease input url link of DA node (Ex: http://10.10.10.10:26659): " 
read DA_URL

if [[ $DA_URL == "" ]]; then
	DA_URL="http://127.0.0.1:26659"
	echo -e "\nYou did not input link of DA node, so default link will be \033[0;31m $DA_URL\033[0m\n"
fi

# Input Namespace 
echo -e "\nPlease input your Namespace ID: " 
read NAMESPACE_ID

if [[ $NAMESPACE_ID == "" ]] ;then
	NAMESPACE_ID=$(echo $RANDOM | md5sum | head -c 16; echo;)
	echo -e "\nYou did not input Namespace ID, so a newly Namespace is generated \033[0;31m$NAMESPACE_ID\033[0m\n"
fi

# Input Rollkit Blocktime
echo -e "\nPlease input Rollkit Blocktime: "
read ROL_BLOCKTIME

if [[ $ROL_BLOCKTIME == "" ]] ; then
        ROL_BLOCKTIME=5;
        echo -e "\nYou did not input Rollkit blocktime, so default blocktime value is \033[0;31m$ROL_BLOCKTIME\033[0m\n"
fi

# Input DA Blocktime 
echo -e "\nPlease input DA Blocktime: "
read DA_BLOCKTIME

if [[ $DA_BLOCKTIME == "" ]]; then
        DA_BLOCKTIME=10;
        echo -e "\nYou did not input DA blocktime, so default blocktime value is \033[0;31m$DA_BLOCKTIME\033[0m\n"
fi

# Query the DA Layer start height, in this case we are querying blockheight from RPC of a consensus fullnode on Celestia-Blockspacerace
# You can check public of Celestia RPC at here: https://docs.celestia.org/nodes/blockspace-race/#rpc-endpoints
DA_BLOCK_HEIGHT=$(expr $(curl https://rpc-blockspacerace.pops.one/block | jq -r '.result.block.header.height') + 1 )
echo $DA_BLOCK_HEIGHT

# start a sequencer of rollkit chain
sudo tee /etc/systemd/system/nibiru-rollkit.service > /dev/null <<EOF
[Unit]
Description=Nibiru rollkit
After=network-online.target

[Service]
User=$USER
ExecStart=$(which nibid) start --rollkit.aggregator true \
	    --rollkit.block_time ${ROL_BLOCKTIME}s \
	    --rollkit.da_block_time ${DA_BLOCKTIME}s \
	    --rollkit.da_layer celestia \
	    --rollkit.da_config='{"base_url":"$DA_URL","timeout":60000000000,"fee":100,"gas_limit":100000}' \
	    --rollkit.namespace_id $NAMESPACE_ID  \
	    --rollkit.da_start_height $DA_BLOCK_HEIGHT \
	    --p2p.laddr "0.0.0.0:26656" \
	    --rpc.laddr "tcp://0.0.0.0:26657" \
	    --grpc.address "0.0.0.0:9090" \
	    --grpc-web.address "0.0.0.0:9091" \
	    --p2p.seed_mode \
	    --log_level debug
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nibiru-rollkit.service
sudo systemctl restart nibiru-rollkit.service

echo -e "\n\033[0;32mCongrat! You have finished setup a sequencer of Nibiru Cosmos-SDK rollup on top of Celestia Blockspace Race !! \033[0m\n"; sleep 1;
echo -e "\nCheck log: \033[0;31msudo journalctl -u nibiru-rollkit.service -f -o cat\033[0m"


echo -e "\n\033[0;32mGenerating script of fullnode setup.....\033[0m"
sleep 20;
# echo -e "\nFor fullnode setup of Nibiru rollup, you can check attached guide"


sudo tee ./Fullnode_setup.txt > /dev/null <<EOF

cd \$HOME
rm -rf nibiru
git clone https://github.com/NibiruChain/nibiru.git
cd \$HOME/nibiru
git checkout v0.19.2

go mod edit -replace github.com/cosmos/cosmos-sdk=github.com/rollkit/cosmos-sdk@$SEL_SDK_VER
go mod edit -replace github.com/tendermint/tendermint=github.com/celestiaorg/tendermint@v0.34.22-0.20221202214355-3605c597500d
#go mod edit -replace github.com/tendermint/tendermint=github.com/celestiaorg/tendermint@$SEL_TEND_VER;
go mod tidy
go mod download
make install

# Set home path of fullnode. Remember to change another path if fullnode is installed on same server with sequencer
NIBI_PATH="\$HOME/.nibid"

# Initialise chain
nibid init $VALIDATOR_NAME --chain-id $CHAIN_ID --home \$NIBI_PATH

# Download genesis.json file created during setup of sequencer, then uploaded to \$NIBI_PATH/config

# NODE ID of Sequencer: $SEQ_NODEID
SEQ_NODEID=$(`which nibid` status | jq .NodeInfo.id -r)

# Get latest DA block height
DA_BLOCK_HEIGHT=\$(expr \$(curl https://rpc-blockspacerace.pops.one/block | jq -r '.result.block.header.height') + 1 )
echo \$DA_BLOCK_HEIGHT


echo -e "
[Unit]
Description=Nibiru rollkit
After=network-online.target

[Service]
User=$USER
ExecStart=\$(which nibid) start --home \${NIBI_PATH} \
            --rollkit.block_time ${ROL_BLOCKTIME}s \
            --rollkit.da_block_time ${DA_BLOCKTIME}s \
            --rollkit.da_layer celestia \
            --rollkit.da_config='{\"base_url\":\"$DA_URL\",\"timeout\":60000000000,\"fee\":100,\"gas_limit\":100000}' \
            --rollkit.namespace_id $NAMESPACE_ID  \
            --rollkit.da_start_height \$DA_BLOCK_HEIGHT \
            --p2p.laddr \"0.0.0.0:26656\" \
            --rpc.laddr \"tcp://0.0.0.0:26657\" \
            --grpc.address \"0.0.0.0:9090\" \
            --grpc-web.address \"0.0.0.0:9091\" \
            --p2p.seeds \"\$SEQ_NODEID@$(curl -s ifconfig.me):26656\" \
            --log_level debug
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/nibiru-rollkit-full.service 

sudo systemctl daemon-reload
sudo systemctl enable nibiru-rollkit-full.service
sudo systemctl restart nibiru-rollkit-full.service

EOF

echo -e "\nFor fullnode setup of Nibiru rollup, you can check attached guide in $(pwd)/Fullnode_setup.txt"
echo -e "\n==================== THE END ===================="
