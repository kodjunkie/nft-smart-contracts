// SPDX-License-Identifier: MIT

pragma solidity >=0.8.13 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721Whitelist is ERC721, Ownable {
	using Strings for uint256;
	using Counters for Counters.Counter;

	Counters.Counter private _supply;

	string private baseURI;
	string private baseExt = ".json";

	bool public revealed = false;
	string private notRevealedUri;

	// Total supply
	uint256 private constant MAX_SUPPLY = 500;

	// Whitelist mint constants
	bool private wlMintActive = false;
	uint256 private constant WL_MAX_PER_WALLET = 3; // 2/wallet (uses < to save gas)
	uint256 private constant WL_MINT_PRICE = 0.05 ether;
	mapping(address => bool) private whitelists;

	// Public mint constants
	bool private pubMintActive = false;
	uint256 private constant PUB_MAX_PER_WALLET = 4; // 3/wallet (uses < to save gas)
	uint256 private constant PUB_MINT_PRICE = 0.065 ether;

	// Track number of tokens per wallet
	mapping(address => uint256) private mintedNFTs;

	bool private _locked = false; // for re-entrancy guard

	// Initializes the contract by setting a `name` and a `symbol`
	constructor(string memory _initBaseURI, string memory _initNotRevealedUri) ERC721("ERC721Whitelist", "ERW") {
		_supply.increment();
		setBaseURI(_initBaseURI);
		setNotRevealedURI(_initNotRevealedUri);
	}

	// Whitelist mint
	function whitelistMint(uint256 _quantity) public payable nonReentrant {
		require(wlMintActive, "Whitelist sale is closed at the moment.");

		address _to = msg.sender;
		require(
			_quantity > 0 && (mintedNFTs[_to] + _quantity) < WL_MAX_PER_WALLET,
			"You cannot purchased more than the allowed limit."
		);
		require(whitelists[_to], "You're not whitelisted.");
		require(msg.value >= (WL_MINT_PRICE * _quantity), "Not enough ETH.");

		mint(_to, _quantity);
	}

	// Public mint
	function publicMint(uint256 _quantity) public payable nonReentrant {
		require(pubMintActive, "Public sale is closed at the moment.");

		address _to = msg.sender;
		require(
			_quantity > 0 && (mintedNFTs[_to] + _quantity) < PUB_MAX_PER_WALLET,
			"You cannot purchased more than the allowed limit."
		);
		require(msg.value >= (PUB_MINT_PRICE * _quantity), "Not enough ETH.");

		mint(_to, _quantity);
	}

	/**
	 * Admin mint
	 * For promotions / collaborations
	 * You can remove this block if you don't need it
	 */
	function adminMint(uint256 _quantity) public onlyOwner {
		mint(owner(), _quantity);
	}

	// Mint an NFT
	function mint(address _to, uint256 _quantity) private {
		require((_quantity + _supply.current()) <= MAX_SUPPLY, "Max supply exceeded.");

		mintedNFTs[_to] = mintedNFTs[_to] + _quantity;

		for (uint256 i = 0; i < _quantity; i++) {
			_safeMint(_to, _supply.current());
			_supply.increment();
		}
	}

	// Activate whitelist sale
	function setWlMintActive() public onlyOwner {
		wlMintActive = true;
	}

	// Activate public sale
	function setPubMintActive() public onlyOwner {
		pubMintActive = true;
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

	// Get number of tokens by address
	function getCountByAddress(address _address) public view returns (uint256) {
		return mintedNFTs[_address];
	}

	// Base URI
	function _baseURI() internal view virtual override returns (string memory) {
		return baseURI;
	}

	// Set base URI
	function setBaseURI(string memory _newBaseURI) public {
		baseURI = _newBaseURI;
	}

	// Get metadata URI
	function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
		require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token.");

		if (revealed == false) {
			return notRevealedUri;
		}

		string memory currentBaseURI = _baseURI();
		return
			bytes(currentBaseURI).length > 0
				? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExt))
				: "";
	}

	// Set reveal
	function reveal() public onlyOwner {
		revealed = true;
	}

	// Set not revealed URI
	function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
		notRevealedUri = _notRevealedURI;
	}

	// Withdraw balance
	function withdraw() external onlyOwner {
		// Transfer the remaining balance to the owner
		// Do not remove this line, else you won't be able to withdraw the funds
		payable(owner()).transfer(address(this).balance);
	}

	// Receive any donation funds sent to the contract
	receive() external payable {}

	// Reentrancy guard modifier
	modifier nonReentrant() {
		require(!_locked, "No re-entrant call.");
		_locked = true;
		_;
		_locked = false;
	}
}
