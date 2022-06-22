const ContributorContract = artifacts.require("ContributorContract");
const UserContract = artifacts.require("UserContract");

const expectRevert = require("@openzeppelin/test-helpers").expectRevert;

contract("ContributorContract", (accounts) => {
  let instance;
  let userContract;
  let [ownerAddress, contr1Address, contr2Address] = accounts;

  const addContributor = async (name, address) => {
    await instance.addContributor(
      name,
      "111.111.111-00",
      "CPF",
      "Brazil",
      "SP",
      "Jundiai",
      "135465-005",
      {from: address}
    );
  };

  beforeEach(async () => {
    userContract = await UserContract.new();

    instance = await ContributorContract.new(userContract.address);

    await userContract.newAllowedCaller(instance.address);

  });

  context("when will create new contributor (.addContributor)", () => {
      context("when contributor exists", () => {
        it("should return error", async () => {
          await addContributor("Contributor A", contr1Address);
          await expectRevert(
            addContributor("Contributor A", contr1Address),
            "This contributor already exist"
          );
      });

      context("when contributor don't exists", () => {
        it("should create contributor", async () => {
          await addContributor("Contributor A", contr1Address);
          await addContributor("Contributor B", contr2Address);
          const contributor = await instance.getContributor(contr1Address);

          assert.equal(contributor.contributorWallet, contr1Address);
        });

        it("should increment contributorCount after create contributor", async () => {
          await addContributor("Contributor A", contr1Address);
          await addContributor("Contributor B", contr2Address);
          const contributorsCount = await instance.contributorsCount();

          assert.equal(contributorsCount, 2);
        });

        it("should add created contributor in contributorList (array)", async () => {
          await addContributor("Contributor A", contr1Address);
          await addContributor("Contributor B", contr2Address);

          const contributors = await instance.getContributors();

          assert.equal(contributors[0].contributorWallet, contr1Address);
        });

        it("should add created contributor in userType contract as a CONTRIBUTOR", async () => {
          await addContributor("Contributor A", contr1Address);

          const userType = await userContract.getUser(contr1Address);
          const CONTRIBUTOR = 6;

          assert.equal(userType, CONTRIBUTOR);
        });
      });
    });
  });

  context("when will get contributors (.getContributors)", () => {
    it("should return contributors when has contributors", async () => {
      await addContributor("Contributor A", contr1Address);
      await addContributor("Contributor B", contr2Address);

      const contributors = await instance.getContributors();

      assert.equal(contributors.length, 2);
    });

    it("should return contributors equal zero when dont has it", async () => {
      const contributors = await instance.getContributors();

      assert.equal(contributors.length, 0);
    });
  });

  context("when will get contributor (.getContributor)", () => {
    it("should return a contributor", async () => {
      await addContributor("Contributor A", contr1Address);

      const contributor = await instance.getContributor(contr1Address);

      assert.equal(contributor.contributorWallet, contr1Address);
    });
  });

  context("when will check if contributor exists", () => {
    it("should return true when exists", async () => {
      await addContributor("Contributor A", contr1Address);
      const contributorExists = await instance.contributorExists(contr1Address);

      assert.equal(contributorExists, true);
    });

    it("it should return false when don't excists", async () => {
      const contributorExists = await instance.contributorExists(contr1Address);

      assert.equal(contributorExists, false);
    })

  });
});
