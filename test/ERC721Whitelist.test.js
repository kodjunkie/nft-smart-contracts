// ERC721Whitelist contract tests
const ERC721Whitelist = artifacts.require("ERC721Whitelist.sol");
const expect = require("../setup-tests").expect;
const BN = web3.utils.BN;

contract("ERC721Whitelist", (accounts) => {
	let instance;
	const [deployer, whitelist, public] = accounts;

	before(async () => {
		instance = await ERC721Whitelist.deployed();
	});

	it("can add to whitelist", async () => {
		expect(instance.isWhitelisted(whitelist)).to.eventually.be.false;
		await instance.toggleWhitelist(whitelist, { from: deployer });
		expect(instance.isWhitelisted(whitelist)).to.eventually.be.true;
	});

	it("can toggle sale state", async () => {
		// Ensure the whitelist and public sale is closed (default)
		expect(instance.wlMintActive()).to.eventually.be.false;
		expect(instance.pubMintActive()).to.eventually.be.false;

		// Toggle sale
		await instance.toggleWlMintActive({ from: deployer });
		await instance.togglePubMintActive({ from: deployer });

		expect(instance.wlMintActive()).to.eventually.be.true;
		expect(instance.pubMintActive()).to.eventually.be.true;
	});

	it("should be able to mint tokens", async () => {
		const quantity = 2;

		// Whitelist
		await instance.whitelistMint(quantity, {
			from: whitelist,
			value: web3.utils.toWei("0.1", "ether"),
			gas: 300000,
		});
		expect(instance.balanceOf(whitelist)).to.eventually.be.a.bignumber.equal(new BN(quantity));

		// Public mint
		await instance.publicMint(quantity, {
			from: public,
			value: web3.utils.toWei("0.13", "ether"),
			gas: 300000,
		});
		expect(instance.balanceOf(public)).to.eventually.be.a.bignumber.equal(new BN(quantity));
	});

	it("throws when max allowed per wallet is exceeded", async () => {
		// Since the whitelisted account already minted 2 NFTs which is the max allowed
		// lets try to mint an extra 1 to see if it passes
		expect(
			instance.whitelistMint(1, { from: whitelist, value: web3.utils.toWei("0.05", "ether"), gas: 300000 })
		).to.eventually.be.rejectedWith("Invalid mint quantity.");

		// Now for public mint
		// We know the public mint account still has 1 mint left
		// But let's try to mint 2 instead
		expect(
			instance.publicMint(2, { from: public, value: web3.utils.toWei("0.13", "ether"), gas: 300000 })
		).to.eventually.be.rejectedWith("Invalid mint quantity.");
	});
});
