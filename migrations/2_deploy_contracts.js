const SatToken = artifacts.require("SatToken");
const IsaPool = artifacts.require("IsaPool");
const CategoryContract = artifacts.require("CategoryContract");
const DeveloperPool = artifacts.require("DeveloperPool");
const Sintrop = artifacts.require("Sintrop");

module.exports = function(deployer) {
  const args = {
    totalTokens: "1500000000000000000000000000",
    tokensPerEra: "833333333333333333333333",
    blocksPerEra: 10,
    eraMax: 18
  }

  deployer.then(async () => {
    await deployer.deploy(Sintrop);

    await deployer.deploy(SatToken, args.totalTokens);

    await deployer.deploy(IsaPool, SatToken.address);
    
    await deployer.deploy(CategoryContract, IsaPool.address);

    await deployer.deploy(
      DeveloperPool, 
      SatToken.address, 
      args.tokensPerEra, 
      args.blocksPerEra, 
      args.eraMax
    );
  });
};