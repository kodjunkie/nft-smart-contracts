// ERC721Whitelist contract tests
const ERC721Whitelist = artifacts.require("ERC721Whitelist.sol");

contract("ERC721Whitelist", (accounts) => {
	let instance;
	const deployer = accounts[0];

	before(async () => {
		instance = await ERC721Whitelist.deployed();
	});

	it("can add to whitelist", async () => {
		const user = accounts[1];

		const notWhitelisted = await instance.isWhitelisted(user);
		assert.equal(notWhitelisted, false, "User already whitelisted.");

		await instance.toggleWhitelist(user, { from: deployer });

		const whitelisted = await instance.isWhitelisted(user);
		assert.equal(whitelisted, true, "Unable to whitelist user.");
	});

	it("can perform whitelist mint", async () => {
		const whitelisted = accounts[1];
		await instance.toggleWlMintActive({ from: deployer });

		await instance.whitelistMint(2, { from: whitelisted, value: web3.utils.toWei("0.1", "ether"), gas: 300000 });
		const minted = await instance.balanceOf(whitelisted);
		assert.equal(minted, 2);
	});
});
