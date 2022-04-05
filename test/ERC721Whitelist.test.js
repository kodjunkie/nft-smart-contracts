// ERC721Whitelist contract tests
const ERC721Whitelist = artifacts.require("ERC721Whitelist.sol");
const expect = require("../setup-tests").expect;
const BN = web3.utils.BN;

contract("ERC721Whitelist", (accounts) => {
	let instance;
	const gas = 300000;

	// Test accounts
	const [, whitelistAcc, publicAcc, otherAcc] = accounts;

	before(async () => {
		instance = await ERC721Whitelist.deployed();
	});

	it("can add to whitelist", async () => {
		// Make sure the whitelist account is not yet whitelisted
		expect(instance.isWhitelisted(whitelistAcc)).to.eventually.be.false;
		// Add whitelist account to whitelist :)
		await instance.toggleWhitelist(whitelistAcc);
		// Verify that the account is now whitelisted
		expect(instance.isWhitelisted(whitelistAcc)).to.eventually.be.true;
	});

	it("can toggle sale state", async () => {
		// Ensure the whitelist and public sale is closed (default)
		expect(instance.wlMintActive()).to.eventually.be.false;
		expect(instance.pubMintActive()).to.eventually.be.false;

		// Toggle sales
		await instance.toggleWlMintActive(); // Whitelist sale
		await instance.togglePubMintActive(); // Public sale

		// Verification
		expect(instance.wlMintActive()).to.eventually.be.true;
		expect(instance.pubMintActive()).to.eventually.be.true;
	});

	it("should be able to perform airdrop mint", async () => {
		const quantity = 1;
		await instance.airDropMint(otherAcc, quantity, { gas });
		expect(instance.balanceOf(otherAcc)).to.eventually.be.a.bignumber.equal(new BN(quantity));
	});

	it("ensures only whitelisted accounts can perform whitelist mint", () => {
		expect(
			instance.whitelistMint(1, { from: publicAcc, value: web3.utils.toWei("0.05", "ether"), gas })
		).to.eventually.be.rejectedWith("You're not whitelisted.");
	});

	it("should be able to mint tokens", async () => {
		const quantity = 2;

		// Whitelist
		await instance.whitelistMint(quantity, {
			from: whitelistAcc,
			value: web3.utils.toWei("0.1", "ether"),
			gas,
		});
		expect(instance.balanceOf(whitelistAcc)).to.eventually.be.a.bignumber.equal(new BN(quantity));

		// Public mint
		await instance.publicMint(quantity, {
			from: publicAcc,
			value: web3.utils.toWei("0.13", "ether"),
			gas,
		});
		expect(instance.balanceOf(publicAcc)).to.eventually.be.a.bignumber.equal(new BN(quantity));
	});

	it("throws when max allowed per wallet is exceeded", () => {
		// Since the whitelisted account already minted 2 NFTs which is the max allowed
		// lets try to mint an extra 1 to see if it passes
		expect(
			instance.whitelistMint(1, { from: whitelistAcc, value: web3.utils.toWei("0.05", "ether"), gas })
		).to.eventually.be.rejectedWith("Invalid mint quantity.");

		// Now for public mint
		// We know the public mint account still has 1 mint left
		// But let's try to mint 2 instead
		expect(
			instance.publicMint(2, { from: publicAcc, value: web3.utils.toWei("0.13", "ether"), gas })
		).to.eventually.be.rejectedWith("Invalid mint quantity.");
	});

	it("should only accept full payment", () => {
		const quantity = 1;

		// Whitelist sale
		expect(
			instance.whitelistMint(quantity, { from: whitelistAcc, value: web3.utils.toWei("0.04", "ether"), gas })
		).to.eventually.be.rejectedWith("Not enough ETH.");

		// Public sale
		expect(
			instance.publicMint(quantity, { from: publicAcc, value: web3.utils.toWei("0.05", "ether"), gas })
		).to.eventually.be.rejectedWith("Not enough ETH.");
	});

	after(() => {
		instance = null;
	});
});
