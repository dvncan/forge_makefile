# Simple forge w/ makefile

The goal of this repo is to show how easy it is to use a makefile with your forge repo to set key values which would typically be passed in the command line

## .env
Please add the env file:
```.env
ENV=testnet
NETWORK=sepolia

RPC_URL=https://alchemy_rpc_url

PRIVATE_KEY=0xsdsjdbsdjsbdjsbdsjdbsdjsbdskdwndew

ETHERSCAN_API_KEY=WTKCFP13......

contract=Counter.sol
```


## More on... Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### database 
Step 1: Install Dependencies

Make sure you have solc and jq installed on your system. You can install them using the following commands:
'''
sudo apt-get update
sudo apt-get install solc
sudo apt-get install jq
'''

Usage

To run the script, use the following command:

chmod +x parseSolidity.sh
./parseSolidity.sh path/to/your/solidity-file.sol json

Replace json with sql or nosql to get the corresponding output format.

### new typescript version 
'run'
ts-node parseSolidity.ts path/to/your/solidity-file.sol

Explanation

	•	solc: Used to generate the AST of the Solidity file.
	•	jq: Used to parse and manipulate the JSON AST.
	•	solidity_type_to_db_type: Converts Solidity types to database types.
	•	parse_solidity_struct: Parses Solidity struct definitions into table definitions.
	•	parse_solidity_contract: Parses Solidity contract definitions into database definitions.
	•	generate_json, generate_sql, generate_nosql: Functions to generate the desired output formats.

This script should handle the basic conversion of Solidity structs and contract variables into appropriate database formats. You can extend it further to handle more complex scenarios and additional Solidity types as needed.

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
