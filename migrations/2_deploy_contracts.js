const CategoryContract = artifacts.require("CategoryContract");

module.exports = function(deployer) {
  deployer.deploy(CategoryContract);

};