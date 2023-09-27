#!/bin/bash

# Function to prompt the user for input and validate it
prompt_and_validate_input() {
  local prompt_message="$1"
  local variable_name="$2"
  local validation_pattern="$3"

  while true; do
    echo "$prompt_message"
    read -r $variable_name  # Remove the double quotes
    if [[ ! ${!variable_name} =~ $validation_pattern ]]; then  # Use ${!variable_name} to access the variable's value
      echo "Invalid input. Please try again."
    else
      break
    fi
  done
}

# Prompt for the number of geth nodes (>0 and <=50)
prompt_and_validate_input "Please enter the number of geth nodes for the network [>0]:" numNodes '^[1-9][0-9]*$'

# Prompt for period value (>=0 and <=60)
prompt_and_validate_input "Please enter the 'period' value (average time(s) interval for adding new blocks to the blockchain) [>=0]:" period '^[0-9]+$|^0$'

# Prompt for chainID value (>0)
prompt_and_validate_input "Please enter the 'chainID' value for genesis.json [>0]:" chainID '^[1-9][0-9]*$'

# Prompt for log saving option (y/n)
prompt_and_validate_input "Do you want to save logs in a .log file? (y/n):" saveLogs '^[ynYN]$'

echo "Number of nodes set to: $numNodes" 
echo "Block period set to: $period seconds" 
echo "Chain ID set to: $chainID" 
echo "Save logs option: $saveLogs"

# Create .env file
touch .env

echo "# blockchain network config" >> .env
echo "NETWORK_ID=$chainID" >> .env
echo "NUM_NODES=$numNodes" >> .env
echo "SAVE_LOGS=$saveLogs" >> .env

# Create the logs directory
mkdir -p logs

# Node creation and account generation
for (( i=1; i<=$numNodes; i++ ))
do
  mkdir "node$i"
  # Generate new account. Assumes password.txt is in the current directory.
  addr=$(geth --datadir node$i account new --password password.txt 2>&1 | grep "Public address of the key" | awk '{print $NF}')

  # Update .env file with node configuration
  echo "# node$i config" >> .env
  echo "IP_NODE_$i=127.0.0.1" >> .env
  echo "ETH_ADDR_NODE_$i=$addr" >> .env
  echo "WS_PORT_NODE_$i=$((3333 + $i))" >> .env
  echo "RPC_PORT_NODE_$i=$((8550 + $i))" >> .env
  echo "ETH_PORT_NODE_$i=$((30302 + $i))" >> .env

  # Generate extraData and alloc parts for genesis.json
  extraData+="${addr#"0x"}"
  alloc+='"'${addr}'": { "balance": "100000000000000000000" },'

  # Prepare node$i_start.sh
  cat << EOF > "node${i}_start.sh"
#!/bin/bash

# Execute the geth init command to initialize the data directory with genesis.json
output=\$(geth init --datadir node$i genesis.json)
echo "\$output"

# Read environment variables from .env file
source .env

# Define the command
command="geth --identity 'node$i' --datadir node$i --syncmode 'full' --ws --ws.addr \$IP_NODE_$i --ws.port \$WS_PORT_NODE_$i --port \$ETH_PORT_NODE_$i --bootnodes \$BOOTNODE_URL --ws.api 'eth,net,web3,personal,miner,admin,clique' --networkid \$NETWORK_ID --nat 'any' --allow-insecure-unlock --authrpc.port \$RPC_PORT_NODE_$i --ipcdisable --unlock \$ETH_ADDR_NODE_$i --password password.txt --mine --snapshot=false --miner.etherbase \$ETH_ADDR_NODE_$i"

# Add verbosity option to the command if logs need to be saved
if [ "\$SAVE_LOGS" == "y" ] || [ "\$SAVE_LOGS" == "Y" ]; then
  command="\$command --verbosity 3 >> ./logs/node$i.log 2>&1"
else
  command="\$command"
fi

# Execute the command
eval \$command
EOF
  
  # Make node$i_start.sh executable
  chmod +x "node${i}_start.sh"

  echo "node$i created and configured." 
done

# Prepare genesis.json (Clique PoA)
cat << EOF > genesis.json
{
  "config": {
    "chainId": $chainID,          
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "muirGlacierBlock": 0,
    "berlinBlock": 0,
    "londonBlock": 0,
    "arrowGlacierBlock": 0,
    "grayGlacierBlock": 0,
    "clique": {
      "period": $period,         
      "epoch": 30000
    }
  },
  "difficulty": "1",
  "gasLimit": "6721975",
  "extraData": "0x0000000000000000000000000000000000000000000000000000000000000000${extraData}0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
  "alloc": {
    ${alloc::-1}
  }
}
EOF

echo "genesis.json created and configured."

# Generate bootnode
mkdir -p bootnode && bootnode -genkey bootnode/boot.key

echo "# bootnode config" >> .env
echo "BOOTNODE_IP=127.0.0.1" >> .env
echo "BOOTNODE_PORT=30302" >> .env
echo "BOOTNODE_KEY=\$(bootnode -writeaddress -nodekey ./bootnode/boot.key)" >> .env
# echo "BOOTNODE_KEY=" >> .env
echo "BOOTNODE_URL=enode://\${BOOTNODE_KEY}@\${BOOTNODE_IP}:0?discport=\${BOOTNODE_PORT}" >> .env

  # Prepare bootnode_start.sh
  cat << EOF > "bootnode_start.sh"
#!/bin/bash

# Read environment variables from .env file
source .env

# Start the bootnode service.
bootnode -nodekey ./bootnode/boot.key -verbosity 9 -addr \$BOOTNODE_IP:\$BOOTNODE_PORT 
EOF

# Make bootnode_start.sh executable
chmod +x "bootnode_start.sh"

echo "bootnode created and configured."