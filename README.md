# Ethereum Network Configurator

Creating a private Ethereum network has become more challenging with the deprecation of Puppeth in Geth 1.11 and the subsequent removal of Ethash (Proof of Work) in Geth 1.12. This repository is designed to simplify and streamline the process of setting up your private Ethereum network.

**Author: Adam Zahir Rodriguez**

------

## Overview

This repository provides a set of scripts that streamline the setup of a private Ethereum network. It offers configuration options for key parameters, including keystore passwords, node data directories, and network specifications like the chainId and block period interval. With these tools, you can easily create and manage a private Ethereum network for your specific needs.

The **bootnode** plays a crucial role in this network, facilitating the association between nodes.

------

## Requirements

- **Geth (Go Ethereum) >= 1.12**: Ensure you have Geth installed with a version equal to or greater than 1.12. You can follow the installation instructions provided in the [official Geth documentation](https://geth.ethereum.org/docs/getting-started/installing-geth).

## Main Scripts

Here are the primary scripts you'll be working with:

- `network_setup.sh`: Use this script to define the number of nodes and specify network parameters like the chain id and block period interval.
- `bootnode_start.sh`: Use this script to run the bootnode, which serves as the entry point for the network.
- `nodeX_start.sh`: These scripts represent nodes responsible for holding validator keys and producing blocks on your private Ethereum network.

## Getting Started

To get started with your private Ethereum network, follow these steps:

1. Execute `./network_setup.sh` to configure your network settings, specifying the number of nodes and network details.

2. Run `./bootnode_start.sh` to start the bootnode.

3. Execute the `./nodeX_start.sh` scripts for starting each node, in any order you prefer.

------

Additionally, this repository includes a Python script, `private_key_decrypt.py`, that allows you to retrieve the private keys of the accounts associated with the nodes in your private Ethereum network. This can be useful for managing and interacting with your network's accounts securely.

To retrieve the private keys, follow these steps:

1. Ensure you have Python 3 installed on your system.

2. Execute the `private_key_decrypt.py` script in the repository's root directory.

The script will search for and decrypt the private keys in the `keystore` directories of your nodes, displaying the private keys in the console.