#!/bin/bash

# Function to convert Solidity type to database type
solidity_type_to_db_type() {
  case $1 in
    uint256|uint)
      echo "INTEGER"
      ;;
    address)
      echo "STRING"
      ;;
    bytes32)
      echo "STRING"
      ;;
    *)
      echo "STRING"
      ;;
  esac
}

# Function to parse Solidity struct and generate table definition
parse_solidity_struct() {
  local struct_name=$1
  local members=$2
  local table="{\"name\": \"$struct_name\", \"columns\": ["
  local first=true

  echo "$members" | jq -c '.[]' | while read -r member; do
    local name=$(echo "$member" | jq -r '.name')
    local type=$(echo "$member" | jq -r '.typeName.name // .typeName.baseTypeName.name')
    local db_type=$(solidity_type_to_db_type "$type")

    if $first; then
      first=false
    else
      table+=","
    fi

    table+="{\"name\": \"$name\", \"type\": \"$db_type\"}"
  done

  table+="]}"
  echo "$table"
}

# Function to parse Solidity contract and generate database definition
parse_solidity_contract() {
  local contract_name=$1
  local sub_nodes=$2
  local database="{\"name\": \"$contract_name\", \"tables\": ["
  local first=true

  echo "$sub_nodes" | jq -c '.[]' | while read -r node; do
    local type=$(echo "$node" | jq -r '.type')
    
    if [ "$type" == "StructDefinition" ]; then
      local struct_name=$(echo "$node" | jq -r '.name')
      local members=$(echo "$node" | jq -c '.members')
      local table=$(parse_solidity_struct "$struct_name" "$members")

      if $first; then
        first=false
      else
        database+=","
      fi

      database+="$table"
    elif [ "$type" == "FunctionDefinition" ]; then
      local function_name=$(echo "$node" | jq -r '.name')
      local columns="[]"
      columns=$(echo "$node" | jq -c '[.body.statements[] | select(.type == "VariableDeclarationStatement") | .variables[0] | {name: .name, typeName: .typeName}]')
      local table=$(parse_solidity_struct "$function_name" "$columns")

      if $first; then
        first=false
      else
        database+=","
      fi

      database+="$table"
    fi
  done

  database+="]}"
  echo "$database"
}

# Function to generate JSON output
generate_json() {
  echo "$1" | jq .
}

# Function to generate SQL output
generate_sql() {
  local database=$1
  local name=$(echo "$database" | jq -r '.name')
  local tables=$(echo "$database" | jq -c '.tables[]')

  echo "CREATE DATABASE $name;"
  echo

  echo "$tables" | while read -r table; do
    local table_name=$(echo "$table" | jq -r '.name')
    local columns=$(echo "$table" | jq -c '.columns[]')

    echo "CREATE TABLE $table_name ("
    first=true

    echo "$columns" | while read -r column; do
      local column_name=$(echo "$column" | jq -r '.name')
      local column_type=$(echo "$column" | jq -r '.type')

      if $first; then
        first=false
      else
        echo ","
      fi

      echo -n "  $column_name $column_type"
    done

    echo
    echo ");"
    echo
  done
}

# Function to generate NoSQL output
generate_nosql() {
  local database=$1
  local name=$(echo "$database" | jq -r '.name')
  local tables=$(echo "$database" | jq -c '.tables[]')

  echo "Database: $name"
  echo

  echo "$tables" | while read -r table; do
    local table_name=$(echo "$table" | jq -r '.name')
    local columns=$(echo "$table" | jq -c '.columns[]')

    echo "Collection: $table_name"
    echo "$columns" | while read -r column; do
      local column_name=$(echo "$column" | jq -r '.name')
      local column_type=$(echo "$column" | jq -r '.type')

      echo "  $column_name: $column_type"
    done

    echo
  done
}

# Main script
if [ -z "$1" ]; then
  echo "Usage: $0 <Solidity file> [format]"
  echo "Formats: json, sql, nosql"
  exit 1
fi

SOLIDITY_FILE=$1
FORMAT=${2:-json}

# Generate AST from Solidity file
AST=$(solc --ast-json "$SOLIDITY_FILE")

# Parse the AST and extract the contract definition
CONTRACT=$(echo "$AST" | jq -c '.children[] | select(.type == "ContractDefinition")')

CONTRACT_NAME=$(echo "$CONTRACT" | jq -r '.name')
SUB_NODES=$(echo "$CONTRACT" | jq -c '.subNodes')

DATABASE=$(parse_solidity_contract "$CONTRACT_NAME" "$SUB_NODES")

case $FORMAT in
  json)
    generate_json "$DATABASE"
    ;;
  sql)
    generate_sql "$DATABASE"
    ;;
  nosql)
    generate_nosql "$DATABASE"
    ;;
  *)
    echo "Invalid format: $FORMAT"
    exit 1
    ;;
esac