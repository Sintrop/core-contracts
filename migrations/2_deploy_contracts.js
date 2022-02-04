const SatToken = artifacts.require("SatToken");
const DeveloperPool = artifacts.require("DeveloperPool");
const Sintrop = artifacts.require("Sintrop");

module.exports = function(deployer) {
  const args = {
    totalTokens: "25000000000000000000000000",
    tokensPerEra: 5000,
    blocksPerEra: 10,
    eraMax: 18
  }

  deployer.deploy(Sintrop);
  deployer.deploy(SatToken, args.totalTokens).then(() => {

    return deployer.deploy(
      DeveloperPool, 
      SatToken.address, 
      args.tokensPerEra, 
      args.blocksPerEra, 
      args.eraMax
    );

  });
};