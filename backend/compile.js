const solc = require("solc");
const fs = require("fs");
const path = require("path");

// dossier contenant tes contrats
const contractsDir = path.resolve(__dirname, "contracts");

// dossier de sortie pour les fichiers compilés
const buildDir = path.resolve(__dirname, "build");
if (!fs.existsSync(buildDir)) fs.mkdirSync(buildDir);

const sources = {};
fs.readdirSync(contractsDir).forEach(file => {
  if (file.endsWith(".sol")) {
    const filePath = path.join(contractsDir, file);
    const source = fs.readFileSync(filePath, "utf8");
    sources[file] = { content: source };
  }
});

const input = {
  language: "Solidity",
  sources: sources, // Pass all sources
  settings: {
    outputSelection: {
      "*": {
        "*": ["abi", "evm.bytecode"]
      }
    }
  }
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));

// Handle compilation errors
if (output.errors) {
  output.errors.forEach(err => {
    console.error(err.formattedMessage);
  });
  if (output.contracts === undefined) {
    console.error("❌ Compilation Solidity échouée : Aucun contrat compilé.");
    process.exit(1);
  }
}

for (const file in output.contracts) { // Iterate through compiled files
  for (const contractName in output.contracts[file]) {
    const abi = output.contracts[file][contractName].abi;
    const bytecode = output.contracts[file][contractName].evm.bytecode.object;

    fs.writeFileSync(path.join(buildDir, `${contractName}.abi.json`), JSON.stringify(abi, null, 2));
    fs.writeFileSync(path.join(buildDir, `${contractName}.bin`), bytecode);
  }
}

console.log("✅ Compilation Solidity terminée !");