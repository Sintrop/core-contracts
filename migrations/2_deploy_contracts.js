const SacToken = artifacts.require("SacToken");
const IsaPool = artifacts.require("IsaPool");
const CategoryContract = artifacts.require("CategoryContract");
const DeveloperPool = artifacts.require("DeveloperPool");
const Sintrop = artifacts.require("Sintrop");
const ProducerContract = artifacts.require("ProducerContract");
const ActivistContract = artifacts.require("ActivistContract");
const UserContract = artifacts.require("UserContract");

module.exports = function (deployer) {
  const args = {
    totalTokens: "1500000000000000000000000000",
    tokensPerEra: "833333333333333333333333",
    blocksPerEra: 10,
    eraMax: 18,
  };

  deployer.then(async () => {
    const userContract = await deployer.deploy(UserContract);

    await deployer.deploy(ActivistContract, UserContract.address);

    await deployer.deploy(ProducerContract, UserContract.address);

    await deployer.deploy(Sintrop,
      ActivistContract.address,
      ProducerContract.address,
      1000
    );

    await deployer.deploy(ActivistContract, UserContract.address);

    await deployer.deploy(ProducerContract, UserContract.address);

    const activistContract = await ActivistContract.deployed();
    const producerContract = await ProducerContract.deployed();

    await activistContract.newAllowedCaller(Sintrop.address);
    await producerContract.newAllowedCaller(Sintrop.address);

    await userContract.newAllowedCaller(activistContract.address);
    await userContract.newAllowedCaller(producerContract.address);

    await deployer.deploy(SacToken, args.totalTokens);

    await deployer.deploy(IsaPool, SacToken.address);

    await deployer.deploy(CategoryContract, IsaPool.address);

    await deployer.deploy(
      DeveloperPool,
      SacToken.address,
      args.tokensPerEra,
      args.blocksPerEra,
      args.eraMax
    );
  });
};
