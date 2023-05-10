# Celestia_Sovereign-Rollup

## A. Introduction
- The part guides how to deploy an existing Cosmos-SDK appchain `Nibiru` as a rollup on top of Celestia Blockspacerace network.
- Scenario of deployment is as below
  * a Rollup sequencer node on server A
  * a Rollup full node on server B
  * a Celestia DA Fullnode on server C
- For installation guide of DA Fullnode, kindly refer below link 
  * [Official guide from Celestia team](https://docs.celestia.org/nodes/celestia-node/)
  * My own script

## B. Installation of Rollup chain
### 1. Install dependencies, if needed
```
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl build-essential git wget jq make gcc tmux chrony lz4 unzip
```

### 2. Install Go
```
ver="1.19.5"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```

### 3. Download script
```
cd $HOME
wget https://raw.githubusercontent.com/viennguyenbkdn/Celestia_Sovereign-Rollup/main/nibiru_rollup.sh
chmod +x nibiru_rollup.sh
```

### 4. Setup `Nibiru` Rollup chain
- Run below script and follow video to setup your node
```
./nibiru_rollup.sh
```

