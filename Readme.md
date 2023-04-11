# ETHNode_Docker

This project contains the files necessary to run a full POS Ethereum Node within a docker framework, with a modified version of geth. 

## Description

The purpose of this project is to run a modified version of geth along side the official version of lighthouse. This allows the user to send transactions (via a wallet) to the Ethereum blockchain without needing an external endpoint provider (for privacy), or to implement MEV strategies in a modified version of geth. 

The Ethereum execution client is chosen to be geth. This project builds a docker image from the latest ethereum/go-client github repo. This allows the user to edit the github repo in order to point the Dockerfile to a modified version of geth, and run a modified geth instead of the official version. 

The Ethereum consensus client is chosen to be lighthouse. The official version of lighthouse is used. 


## Usage

Clone this repo and cd into it. 

### Dependencies

* This package assumes you have docker and docker-compose installed. 

### Directory Layout 

To have a persistent geth and lighthouse data directory outside of the docker containers that is consistent with the docker-compose.yaml file, run the following commands. 
```
mkdir -p $HOME/ETHNode/geth_datadir 
mkdir -p $HOME/ETHNode/lighthouse_datadir 
mkdir -p $HOME/ETHNode/JWT 
```

To use a different project structure, modify the docker-compose.yaml file. 

### Create the jwtsecret

In order for the consensus client to communicate securely with the execution client (over the 8551 port), they need to share a 32 hexadecimal JasonWebToken (JWT) token. Generate this by 

```
openssl rand -hex 32 | tr -d "\n" > "$HOME/ETHNode/JWT/jwtsecret"
```

### Build The Local GETH Image 

The Dockerfile contains the instructions to clone the official ethereum/go-client github repo, compile it, expose the needed ports, and execute geth. The docker image can be made smaller if needed. To use a forked version of geth, change the cloned directory in the Dockerfile. To build the geth image and name it "geth-local", run  

```
docker build -t geth-local . 
```

Note the docker-compose.yaml file assumes the geth image is called geth-local. 

### Pull The Official Lighthouse Docker Image

```
docker pull sigp/lighthouse:latest
```

Check that the image runs: 

```
docker run sigp/lighthouse:latest lighthouse --version 
```

### Run The Full Ethereum Node As a Service 

The docker-compose.yaml file contains the instructions to start a docker network and run the geth and lighthouse clients as services, exposing the correct ports, and persisting the data directories.

```
docker-compose up -d 
```

To stop the ethereum node from running, run
```
docker-compose stop
```

To check the logs from the geth or lighthouse containers, run docker logs on the container names (which are specified in the docker-compose.yaml file), via 
```
docker logs -f geth-mainnet 
docker logs -f lighthouse_beacon
```

Exit using ctrl-c. Prune the images and containers to clean the docker environment. 

### Read And Write To The Node

Once the node is running, it should be possible to send commands to the RPC endpoint. To determine if your node is synced, run the following on the machine where the node is hosted:
```
curl --location --request POST '127.0.0.1:8545' --header 'Content-Type: application/json' --data-raw '{
	"jsonrpc": "2.0",
	"id": 1,
	"method": "eth_syncing",
	"params": []          	 
}'
```

Any result apart from "False" indicates that the node is not fully synced. After the node is synced, it is possible to read the state and post transactions to the node. For example, to find the eth balance of an address, run:
```
curl --location --request POST '127.0.0.1:8545' --header 'Content-Type: application/json' --data-raw '{
	"jsonrpc": "2.0",
	"id": 1,
	"method": "eth_getBalance",
	"params": ["0x3DdfA8eC3052539b6C9549F12cEA2C295cfF5296", "latest"]
}'
```


## To Do

* Modify geth to stop propagation of all transactions except those on a whitelist
* Set up node monitoring 



## Version History

* 0.1
    * Initial Release: Runs a Ethereum Node with an official version of geth in conjunction the with the official lighthouse docker image.  

## License

This project is licensed under the MIT License as given in License.txt

