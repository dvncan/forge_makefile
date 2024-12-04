// npm install solidity-parser-antlr

// parseSolidity.ts
import fs from 'fs';
import parser from 'solidity-parser-antlr';

interface Column {
  name: string;
  type: string;
}

interface Table {
  name: string;
  columns: Column[];
}

interface Database {
  name: string;
  tables: Table[];
}

function solidityTypeToDBType(solType: string): string {
  switch (solType) {
    case 'uint256':
    case 'uint':
      return 'INTEGER';
    case 'address':
      return 'STRING';
    case 'bytes32':
      return 'STRING';
    default:
      return 'STRING';
  }
}

function parseSolidityStruct(structNode: any): Table {
  const columns: Column[] = structNode.members.map((member: any) => ({
    name: member.name,
    type: solidityTypeToDBType(member.typeName.name || member.typeName.baseTypeName.name),
  }));
  return {
    name: structNode.name,
    columns,
  };
}

function parseSolidityContract(contractNode: any): Database {
  const database: Database = {
    name: contractNode.name,
    tables: [],
  };

  contractNode.subNodes.forEach((node: any) => {
    if (node.type === 'StructDefinition') {
      database.tables.push(parseSolidityStruct(node));
    } else if (node.type === 'FunctionDefinition') {
      const columns: Column[] = node.body.statements
        .filter((stmt: any) => stmt.type === 'VariableDeclarationStatement')
        .map((stmt: any) => ({
          name: stmt.variables[0].name,
          type: solidityTypeToDBType(stmt.variables[0].typeName.name),
        }));

      database.tables.push({
        name: node.name,
        columns,
      });
    }
  });

  return database;
}

function generateJSON(database: Database): string {
  return JSON.stringify(database, null, 2);
}

function generateSQL(database: Database): string {
  let sql = `CREATE DATABASE ${database.name};\n`;

  database.tables.forEach((table) => {
    sql += `CREATE TABLE ${table.name} (\n`;
    table.columns.forEach((column, index) => {
      sql += `  ${column.name} ${column.type}`;
      if (index < table.columns.length - 1) sql += ',';
      sql += '\n';
    });
    sql += `);\n`;
  });

  return sql;
}

function generateNoSQL(database: Database): string {
  let nosql = `Database: ${database.name}\n`;

  database.tables.forEach((table) => {
    nosql += `Collection: ${table.name}\n`;
    table.columns.forEach((column) => {
      nosql += `  ${column.name}: ${column.type}\n`;
    });
  });

  return nosql;
}

function parseSolidityFile(filePath: string) {
  const content = fs.readFileSync(filePath, 'utf8');
  const ast = parser.parse(content, { tolerant: true });

  ast.children.forEach((node: any) => {
    if (node.type === 'ContractDefinition') {
      const database = parseSolidityContract(node);
      console.log('JSON Format:\n', generateJSON(database));
      console.log('SQL Format:\n', generateSQL(database));
      console.log('NoSQL Format:\n', generateNoSQL(database));
    }
  });
}

const filePath = process.argv[2];
if (filePath) {
  parseSolidityFile(filePath);
} else {
  console.error('Please provide a Solidity file path.');
}