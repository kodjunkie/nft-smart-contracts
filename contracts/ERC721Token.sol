// SPDX-License-Identifier: MIT

pragma solidity >=0.8.13 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721Token is ERC721, Ownable {
	using Counters for Counters.Counter;
	Counters.Counter private _supply;

	// Total supply
	uint256 private constant MAX_SUPPLY = 500;

	// Whitelist mint constants
	uint256 private constant WL_MAX_PER_WALLET = 3; // 2/wallet (uses < to save gas)
	uint256 private constant WL_MINT_PRICE = 0.05 ether;

	mapping(address => bool) private whitelists;

	// Public mint constants
	uint256 private constant PUB_MAX_PER_WALLET = 4; // 3/wallet (uses < to save gas)
	uint256 private constant PUB_MINT_PRICE = 0.065 ether;

	// Track token per wallet
	mapping(address => uint256) private mintedNFTs;

	bool private _saleIsActive = false;
	bool private _locked = false; // for re-entrancy guard

	// Initializes the contract by setting a `name` and a `symbol`
	constructor() ERC721("ERC721Token", "ERC") {
		_supply.increment();
	}

	// Whitelist mint
	function whitelistMint(uint256 _quantity) public payable nonReentrant {
		require(_saleIsActive, "Sale is closed at the moment.");

		address _to = msg.sender;
		require(whitelists[_to], "You're not whitelisted.");
		require(msg.value >= (WL_MINT_PRICE * _quantity), "Not enough ETH.");
		require((mintedNFTs[_to] + _quantity) < WL_MAX_PER_WALLET, "You cannot purchased more than the allowed limit.");

		mint(_to, _quantity);
	}

	// Public mint
	function publicMint(uint256 _quantity) public payable nonReentrant {
		require(_saleIsActive, "Sale is closed at the moment.");
		require(msg.value >= (PUB_MINT_PRICE * _quantity), "Not enough ETH.");

		address _to = msg.sender;
		require(
			(mintedNFTs[_to] + _quantity) < PUB_MAX_PER_WALLET,
			"You cannot purchased more than the allowed limit."
		);

		mint(_to, _quantity);
	}

	// Admin mint
	// For promotions & collabs
	function adminMint(uint256 _quantity) public onlyOwner {
		mint(owner(), _quantity);
	}

	// Mint an NFT
	function mint(address _to, uint256 _quantity) private {
		require((_quantity + _supply.current()) <= MAX_SUPPLY, "NFTs sold out.");

		mintedNFTs[_to] = mintedNFTs[_to] + _quantity;

		for (uint256 i = 0; i < _quantity; i++) {
			_safeMint(_to, _supply.current());
			_supply.increment();
		}
	}

	// Toggle sales activity
	function toggleSale() public onlyOwner {
		_saleIsActive = !_saleIsActive;
	}

	// Set whitelist
	function toggleWhitelist(address _address) public onlyOwner {
		whitelists[_address] = !whitelists[_address];
	}

	// Get total supply
	function totalSupply() public view returns (uint256) {
		return _supply.current();
	}

	// Get whitelist
	function isWhitelisted(address _address) public view returns (bool) {
		return whitelists[_address];
	}

	// Get number of tokens per wallet
	function getNFTsPerWallet(address _address) public view returns (uint256) {
		return mintedNFTs[_address];
	}

	// Withdraw balance
	function withdraw() external onlyOwner {
		payable(owner()).transfer(address(this).balance);
	}

	// Receive any donation funds sent to the contract
	receive() external payable {}

	// Reentrancy guard modifier
	modifier nonReentrant() {
		require(!_locked, "No re-entrant call");
		_locked = true;
		_;
		_locked = false;
	}
}
