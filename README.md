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
https://github.com/viennguyenbkdn/Celestia_Sovereign-Rollup/assets/91453629/d43403e4-1ec0-4942-ac4f-a6292e8c508b

- Check log of Sequencer node
```
sudo journalctl -u nibiru-rollkit.service -f -o cat
```
![image](https://github.com/viennguyenbkdn/Celestia_Sovereign-Rollup/assets/91453629/18ff302b-0d02-4ae6-8b89-5b21abc05cb3)

- There are some PFB transactions to be submitted to Blockspacerace network via your DA node. You can check detail PFB from [link](https://testnet.mintscan.io/celestia-incentivized-testnet).
![image](https://github.com/viennguyenbkdn/Celestia_Sovereign-Rollup/assets/91453629/f1dd4e23-e1a8-47ea-8cd8-b26d5e18de61)

#### 4.2 Full Node
- After running script in step 4.1, the script generates a file `Fullnode_setup.txt` which guides you how to setup a rollup fullnode on same rollup chain.
![image](https://github.com/viennguyenbkdn/Celestia_Sovereign-Rollup/assets/91453629/ec9000ff-b8cf-45cf-9c91-cac761e6d329)

- The file `Fullnode_setup.txt` contains all information of rollup chain with created `namespaceid`, `sequencer id`, `sequencer IP`,...etc
- If you intend to build a rollup fullnode on same rollup chain, kindly refer the guide to setup.
![image](https://github.com/viennguyenbkdn/Celestia_Sovereign-Rollup/assets/91453629/2dfdaea1-e35f-490f-8f9d-d4e72bca5b96)

- **REMIND**:  
  _- Currently Rollkit Fullnode still have some bugs and can be stucked if Fullnode does not retrieve block data. So i will keep to update more after the issue is solved by Celestia team._ 
  
  _- PR link: https://github.com/celestiaorg/celestia-node/issues/2106_

