const ERC721Whitelist = artifacts.require("ERC721Whitelist");
const ERC721Simple = artifacts.require("ERC721Simple");

module.exports = async function (deployer) {
	// An ipfs:// or http(s):// URL to assets
	const baseUrl = "http://assets.example.com/";

	// To deploy the whitelist supported contract
	// deployer.deploy(ERC721Whitelist, baseUrl, `${baseUrl}hidden.json`);

	// To deploy the simple contract
	deployer.deploy(ERC721Simple, baseUrl);
};
