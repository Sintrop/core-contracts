const Registrable = artifacts.require("Registrable");

const expectRevert = require("@openzeppelin/test-helpers").expectRevert;

contract("Registrable", (accounts) => {
  let instance;
  let [owner, user1Address, user2Address] = accounts;

  beforeEach(async () => {
    instance = await Registrable.new();
  });

  it("should return error when .newAllowedResearcher and is not owner", async () => {
    await expectRevert(
      instance.newAllowedResearcher(user1Address, {from: user1Address}),
      "Ownable: caller is not the owner"
    );
  });

  it("should add .newAllowedResearcher when is owner", async () => {
    await instance.newAllowedResearcher(owner);

    const allowedResearcher = await instance.allowedResearcher(owner);

    assert.equal(allowedResearcher, true);
  });

  it("should be able to add many callers .newAllowedResearcher when is owner", async () => {
    await instance.newAllowedResearcher(owner);
    await instance.newAllowedResearcher(user1Address);
    await instance.newAllowedResearcher(user2Address);

    const allowedResearcher1 = await instance.allowedResearcher(owner);
    const allowedResearcher2 = await instance.allowedResearcher(owner);
    const allowedResearcher3 = await instance.allowedResearcher(owner);

    assert.equal(allowedResearcher1, true);
    assert.equal(allowedResearcher2, true);
    assert.equal(allowedResearcher3, true);
  });
});
