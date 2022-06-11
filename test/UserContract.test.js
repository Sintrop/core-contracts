const UserContract = artifacts.require("UserContract");

const expectRevert = require("@openzeppelin/test-helpers").expectRevert;

contract("UserContract", (accounts) => {
  let instance;
  let [owner, user1Address, user2Address] = accounts;

  let userTypes = {
    Producer: 0,
    Activist: 1,
    Researcher: 2,
    Developer: 3,
    Adviser: 4,
    Contributor: 5,
    Investor: 6,
  };

  const definedTypes = {
    0: "PRODUCER",
    1: "ACTIVIST",
    2: "RESEARCHER",
    3: "DEVELOPER",
    4: "ADVISER",
    5: "CONTRIBUTOR",
    6: "INVESTOR",
  };

  const addUser = async (address, userType, caller) => {
    await instance.addUser(address, userType, {from: caller});
  };

  beforeEach(async () => {
    instance = await UserContract.new();

    await instance.newAllowedCaller(owner);
  });

  it("should add new user with success when allowed caller", async () => {
    await addUser(user1Address, userTypes.Producer, owner);

    const user = await instance.getUser(user1Address);

    assert.equal(user, userTypes.Producer);
  });

  it("should return error message when not allowed caller try add new user", async () => {
    await expectRevert(
      addUser(user1Address, userTypes.Producer, user1Address),
      "Not allowed caller"
    );
  });

  it("should usersCount be zero when not has user", async () => {
    const usersCount = await instance.usersCount();

    assert.equal(usersCount, 0);
  });

  it("should increment usersCount when add new user", async () => {
    await addUser(user1Address, userTypes.Producer, owner);

    const usersCount = await instance.usersCount();

    assert.equal(usersCount, 1);
  });

  it("should add correct enum to producer", async () => {
    await addUser(user1Address, userTypes.Producer, owner);

    const user = await instance.getUser(user1Address);

    assert.equal(user, userTypes.Producer);
  });

  it("should add correct enum to activist", async () => {
    await addUser(user1Address, userTypes.Activist, owner);

    const user = await instance.getUser(user1Address);

    assert.equal(user, userTypes.Activist);
  });

  it("should add correct enum to researcher", async () => {
    await addUser(user1Address, userTypes.Researcher, owner);

    const user = await instance.getUser(user1Address);

    assert.equal(user, userTypes.Researcher);
  });

  it("should add correct enum to developer", async () => {
    await addUser(user1Address, userTypes.Developer, owner);

    const user = await instance.getUser(user1Address);

    assert.equal(user, userTypes.Developer);
  });

  it("should add correct enum to adviser", async () => {
    await addUser(user1Address, userTypes.Adviser, owner);

    const user = await instance.getUser(user1Address);

    assert.equal(user, userTypes.Adviser);
  });

  it("should add correct enum to contributor", async () => {
    await addUser(user1Address, userTypes.Contributor, owner);

    const user = await instance.getUser(user1Address);

    assert.equal(user, userTypes.Contributor);
  });

  it("should add correct enum to investor", async () => {
    await addUser(user1Address, userTypes.Investor, owner);

    const user = await instance.getUser(user1Address);

    assert.equal(user, userTypes.Investor);
  });

  it("should have enums", async () => {
    const types = await instance.userTypes();

    assert.equal(JSON.stringify(types), JSON.stringify(definedTypes));
  });

  it("should add new allowed caller with sucess when is owner", async () => {
    await instance.newAllowedCaller(user1Address, {from: owner});
  });

  it("should return error message when try add new allowed caller and is not owner", async () => {
    await expectRevert(
      instance.newAllowedCaller(user1Address, {from: user1Address}),
      "Ownable: caller is not the owner"
    );
  });
});
