const ERC721Whitelist = artifacts.require("ERC721Whitelist");

module.exports = async function (deployer) {
	// An ipfs:// or http(s):// URL to assets
	const baseUrl = "http://assets.example.com/";
	deployer.deploy(ERC721Whitelist, baseUrl, `${baseUrl}hidden.json`);
};
