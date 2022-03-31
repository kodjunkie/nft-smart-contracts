require("dotenv").config({ path: "../.env" });

const env = process.env;

module.exports = {
	// Local Network
	port: 8545,
	host: "127.0.0.1",
	network_id: 1337,

	// HD Wallet Provider
	mnemonic: env.MNEMONIC,

	// Infura project IDs
	infura: {
		mainnet: env.INFURA_MAINNET,
		rinkeby: env.INFURA_RINKEBY,
	},
};
