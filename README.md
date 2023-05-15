# Setup Sovereign Rollup chain `NIBIRU` on top of Celestia BlockspaceRace DA network 

## A. Introduction
- The part guides how to deploy an existing Cosmos-SDK appchain `Nibiru` as a rollup on top of Celestia Blockspacerace network.
- Scenario of deployment is as below
  * a Rollup sequencer node on server A
  * a Rollup full node on server B
  * a Celestia DA Fullnode on server C
- For installation guide of DA Full/Light node, kindly refer below link 
  * [Celestia's official guide](https://docs.celestia.org/nodes/celestia-node/)
  * My owned script for [Fullnode](https://github.com/viennguyenbkdn/Cosmos/blob/main/Celestia/Fullnode_Setup.md) or [Lightnode](https://github.com/viennguyenbkdn/Cosmos/blob/main/Celestia/Lightnode_setup.md)

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
#### 4.1 Sequencer Node
- Run below script and follow attached video to setup your Sequencer node on the rollup chain
```
./nibiru_rollup.sh
```
https://github.com/viennguyenbkdn/Celestia_Sovereign-Rollup/assets/91453629/0d647c35-b05c-41ec-baab-1b6414229294

- Check log of Sequencer node
```
sudo journalctl -u nibiru-rollkit.service -f -o cat
```
![image](https://github.com/viennguyenbkdn/Celestia_Sovereign-Rollup/assets/91453629/8a6474a9-b04a-4069-ab9f-3787f3056823)

- There are some PFB transactions to be submitted to Blockspacerace network via your DA node. You can check detail PFB from [link](https://testnet.mintscan.io/celestia-incentivized-testnet).
![image](https://github.com/viennguyenbkdn/Celestia_Sovereign-Rollup/assets/91453629/d7ed3e23-1fa6-4e10-a9db-8f10286d80eb)

#### 4.2 Full Node
- After running script in step 4.1, the script generates a file `Fullnode_setup.txt` which guides you how to setup a rollup fullnode on same rollup chain.
![image](https://github.com/viennguyenbkdn/Celestia_Sovereign-Rollup/assets/91453629/5d36555d-c703-4aec-bc4b-1ebc2ac4374b)

- The file `Fullnode_setup.txt` contains all information of rollup chain with created `namespaceid`, `sequencer id`, `sequencer IP`,...etc
- If you intend to build a rollup fullnode on same rollup chain, kindly refer the guide to setup.
![image](https://github.com/viennguyenbkdn/Celestia_Sovereign-Rollup/assets/91453629/2f62f1e2-f135-47fd-a9ff-5a60f44ce517)

- **REMIND**:  
  _- Currently Rollkit Fullnode still have some bugs and can be stucked if Fullnode does not retrieve block data. So i will keep to update more after the issue is solved by Celestia team._ 
  
  _- PR link: https://github.com/celestiaorg/celestia-node/issues/2106_

