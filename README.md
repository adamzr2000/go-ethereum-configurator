# Ethereum Network Configurator

Creating a private Ethereum network has become more challenging with the deprecation of Puppeth in Geth 1.11 and the subsequent removal of Ethash (Proof-of-Work) in Geth 1.12. This repository is designed to simplify and streamline the process of setting up your private Ethereum network.

**Author: Adam Zahir Rodriguez**

------

## Overview

This repository provides a set of scripts that streamline the setup of a private Ethereum network. It offers configuration options for key parameters, including keystore passwords, node data directories, and network specifications like the chain id and block period interval. With these tools, you can easily create and manage a private Ethereum network for your specific needs.

We will use [Clique (Proof-of-authority)](https://github.com/ethereum/EIPs/issues/225) protocol to setup the private network. This protocol is maintaining the block structure as in PoW Ethereum, however instead of mining nodes competing to solve a difficult puzzle, there are pre-elected authorized signer nodes that can generate new blocks at any time. Each new block is endorsed by the list of signers and the last signer node is responsible for populating the new block with transactions. The transaction reward for each new block created is shared between all the signers. 

The **bootnode** plays a crucial role in this network, facilitating the association between nodes.

------

## Requirements

- **Geth (Go Ethereum) >= 1.12**: Make sure to install Geth with a version equal to or greater than 1.12. You can follow the installation instructions provided in the [official Geth documentation](https://geth.ethereum.org/docs/getting-started/installing-geth).

## Main Scripts

Here are the primary scripts you'll be working with:

- `network_setup.sh`: Configure key network settings such as the number of nodes, chain ID, and block period interval. This script generates a *bootnode_start.sh* script and N *nodeX_start.sh* scripts.
- `bootnode_start.sh`: Run this script to start the bootnode, which acts as the entry point for the network.
- `nodeX_start.sh`: These scripts represent nodes responsible for holding validator keys and producing blocks on your private Ethereum network.

## Getting Started

To initiate your private Ethereum network, follow these steps:

1. Execute `./network_setup.sh` to configure your network settings, specifying the number of nodes and network details.

2. Start the bootnode by running `./bootnode_start.sh`.

3. Execute the `./nodeX_start.sh` scripts for starting each node, in any order you prefer.

Note: To add more nodes to the network, run the `./add_node.sh` file, specifying the number of new nodes. Then, execute the `./nodeX_start.sh` scripts for each new node. To participate in consensus, new nodes must be accepted as "sealers" by at least (NUMBER_OF_TOTAL_SIGNERS / 2) + 1 nodes. Propose new signers nodes with the following command:

```
geth --exec "clique.propose(\"ADDRESS_OF_THE_NEW_NODE\",true)" attach ws://localhost:PORT_OF_THE_CURRENT_SIGNER
```
------

## Useful Commands:

Check the number of peers to verify that the nodes have associated correctly:
```
geth --exec "net.peerCount" attach ws://localhost:3334
```

Check signer addresses of the network:
```
geth --exec "clique.getSigners()" attach ws://localhost:3334
```

Check the balance of an account (replace eth.accounts[0] with the account address you want to check):
```
geth --exec "eth.getBalance(eth.accounts[0])" attach ws://localhost:3334
```

Send a transaction:
```
geth --exec "web3.eth.sendTransaction({from:eth.accounts[0],to:\"RECIPIENT_ADDRESS\",value:2500})" attach ws://localhost:3334
```

To launch a JavaScript console, use the following command:
```
geth attach ws://localhost:3334
```
This will allow you to interact with the Ethereum network through the geth node using the JavaScript console.

------

Additionally, this repository includes a Python script, `private_key_decrypt.py`, that allows you to retrieve the private keys of the accounts associated with the nodes in your private Ethereum network. This can be useful for managing and interacting with your network's accounts securely.

To retrieve the private keys, follow these steps:

1. Ensure you have Python 3 installed on your system.

2. Execute the `private_key_decrypt.py` script in the repository's root directory.

The script will search for and decrypt the private keys in the `keystore` directories of your nodes, displaying the private keys in the console.


---
