const ERC721Token = artifacts.require("ERC721Token");

module.exports = async function (deployer) {
  deployer.deploy(ERC721Token);
};
