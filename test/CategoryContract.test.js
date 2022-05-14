const CategoryContract = artifacts.require("CategoryContract");
const SacToken = artifacts.require("SacToken");
const IsaPool = artifacts.require("IsaPool");

contract('CategoryContract', (accounts) => {
  let instance;
  let sacToken;
  let isaPool;
  let [msgSender, user1Address, user2Address] = accounts;

  const addCategory = async (name) => {
    await instance.addCategory(
      name,
      `Está categoria visa avaliar as qualidades do ${name}`,
      `${name} totalmente sustentável`,
      `${name} parcialmente sustentável`,
      `${name} neutro`,
      `${name} parcialmente não sustentável`,
      `${name} totalmente não sustentável`
    )
  }

  const transferTokensTo = async (userAddress, tokens) => {
    await sacToken.transfer(userAddress, tokens);
  }

  const balanceOf = async (userAddress) => {
    return await sacToken.balanceOf(userAddress);
  }

  beforeEach(async () => {
    sacToken = await SacToken.new("1500000000000000000000000000");
    isaPool = await IsaPool.new(sacToken.address);

    await sacToken.addContractPool(isaPool.address, "0")

    instance = await CategoryContract.new(isaPool.address);
    await isaPool.changeAllowedCaller(instance.address);
  })

  it("should create category", async () => {
    await addCategory("Solo");
    const categories = await instance.getCategories();

    assert.equal(categories[0].name, "Solo")
  })

  it("should add msg.sender in createdBy", async () => {
    await addCategory("Solo");

    const category = await instance.categories(1)

    assert.equal(category.createdBy, msgSender)
  })

  it("should increment id of category when created", async () => {
    await addCategory("Solo");
    await addCategory("Solo 2");

    const categories = await instance.getCategories();

    assert.equal(categories[1].id, 2)
  })

  it("should increment total of categories after a new is added", async () => {
    await addCategory("Solo");
    await addCategory("Solo 2");
    const categoryCounts = await instance.categoryCounts();

    assert.equal(categoryCounts, 2)
  })

  it("should return category list after when call getCategories", async () => {
    await addCategory("Solo");
    await addCategory("Solo2");
    const categories = await instance.getCategories();

    assert.equal(categories.length, 2)
  })

  it("should be the same category in category and category list based on position", async () => {
    await addCategory("Solo");
    await addCategory("Solo 2");
    const categoriesList = await instance.getCategories();
    const category = await instance.categories(2);

    assert.equal(categoriesList[1].id, category.id)
  })

  it("should create category with votes equal 0", async () => {
    await addCategory("Solo");
    const categories = await instance.getCategories();

    assert.equal(parseInt(categories[0].votesCount), 0)
  })

  it("when user try vote and category dont exists should return error message", async () => {
    await instance.vote(1, 0)
      .then(assert.fail)
      .catch((error) => {
        assert.equal(error.reason, "This category don't exists")
      })
  })

  it("should vote and send tokens only to the passed id", async () => {
    await addCategory("Solo");
    await instance.vote(1, "100000000000000000000");

    const votes1 = await instance.votes(1);
    const votes2 = await instance.votes(2);

    assert.equal(votes1, "100000000000000000000");
    assert.equal(votes2, 0);
  })

  it("should increment 100 tokens when call vote function and send 100 tokens", async () => {
    await addCategory("Solo");
    await instance.vote(1, "100000000000000000000");

    const votes = await instance.votes(1);

    assert.equal(votes, "100000000000000000000");
  })

  it("should have 150 tokens when call vote function and send 100 tokens and already have 50 tokens", async () => {
    await addCategory("Solo");
    await instance.vote(1, "50000000000000000000");
    await instance.vote(1, "100000000000000000000");

    const votes = await instance.votes(1);

    assert.equal(votes, "150000000000000000000");
  })

  it("should set amount of tokens that the user voted to category id when vote", async () => {
    await addCategory("Solo 1");
    await addCategory("Solo 2");
    await instance.vote(1, "100000000000000000000");
    await instance.vote(2, "50000000000000000000");

    const voted1 = await instance.voted(msgSender, 1);
    const voted2 = await instance.voted(msgSender, 2);
    const voted3 = await instance.voted(msgSender, 3);

    assert.equal(voted1, "100000000000000000000");
    assert.equal(voted2, "50000000000000000000");
    assert.equal(voted3, 0);
  })

  it("should start with voted zero categories", async () => {
    await addCategory("Solo 1");
    await addCategory("Solo 2");

    const voted1 = await instance.voted(msgSender, 1);
    const voted2 = await instance.voted(msgSender, 0);

    assert.equal(voted1, 0);
    assert.equal(voted2, 0);
  })

  it("should increment vote of users in same category", async () => {
    await addCategory("Solo 1");

    await transferTokensTo(user1Address, "50000000000000000000000");
    await transferTokensTo(user2Address, "50000000000000000000000");

    await instance.vote(1, "100000000000000000000", { from: user1Address });
    await instance.vote(1, "100000000000000000000", { from: user2Address });

    const votes = await instance.votes(1);

    assert.equal(votes, "200000000000000000000");
  })

  it("when more than one user voted in one category each user must have your tokens part", async () => {
    await addCategory("Solo 1");

    await transferTokensTo(user1Address, "50000000000000000000000");
    await transferTokensTo(user2Address, "50000000000000000000000");

    await instance.vote(1, "100000000000000000000", { from: user1Address });
    await instance.vote(1, "100000000000000000000", { from: user2Address });

    const votes1 = await instance.voted(user1Address, 1);
    const votes2 = await instance.voted(user2Address, 1);

    assert.equal(votes1, "100000000000000000000");
    assert.equal(votes2, "100000000000000000000");
  })

  it("should return error message when try vote and dont has SAC Tokens", async () => {
    await addCategory("Solo");
    await instance.vote(1, 0, { from: user1Address })
      .then(assert.fail)
      .catch((error) => {
        assert.equal(error.reason, "You don't have tokens to vote")
      })
  })

  it("should return error message when try vote and has tokens but dont send any", async () => {
    await addCategory("Solo");
    await instance.vote(1, 0)
      .then(assert.fail)
      .catch((error) => {
        assert.equal(error.reason, "Send at least 1 SAC Token")
      })
  })

  it("should subtract tokens from user after vote in a category", async () => {
    await addCategory("Solo");
    await transferTokensTo(user1Address, "50000000000000000000000");
    await instance.vote(1, "1000000000000000000000", { from: user1Address });

    const balanceOf = await isaPool.balanceOf(user1Address);

    assert.equal(balanceOf, "49000000000000000000000");
  })

  it("should add tokens to isa pool after vote in a category", async () => {
    await addCategory("Solo");
    await transferTokensTo(user1Address, "50000000000000000000000");
    await instance.vote(1, "1000000000000000000000", { from: user1Address });

    const balance = await isaPool.balance();

    assert.equal(balance, "1000000000000000000000");
  })

  it("should increment tokens in isa pool after many user votes", async () => {
    await addCategory("Solo");
    await transferTokensTo(user1Address, "50000000000000000000000");
    await transferTokensTo(user2Address, "50000000000000000000000");
    await instance.vote(1, "1000000000000000000000", { from: user1Address });
    await instance.vote(1, "5000000000000000000000", { from: user2Address });

    const balance = await isaPool.balance();

    assert.equal(balance, "6000000000000000000000");
  })

  it("when user try unvote and category dont exists should return error message", async () => {
    await instance.unvote(1)
      .then(assert.fail)
      .catch((error) => {
        assert.equal(error.reason, "This category don't exists")
      })
  })

  it("should decrement votesCount in 1 when unvote with success", async () => {
    await addCategory("Solo");
    await transferTokensTo(user1Address, "50000000000000000000000");

    await instance.vote(1, "100000000000000000000", { from: user1Address });
    await instance.vote(1, "100000000000000000000");
    await instance.unvote(1);

    const category = await instance.categories(1);

    assert.equal(category.votesCount, 1);
  })

  it("should return error message when user try unvote and dont voted yet", async () => {
    await addCategory("Solo 1");

    await instance.vote(1, "100000000000000000000");

    await instance.unvote(1, { from: user1Address })
      .then(assert.fail)
      .catch((error) => {
        assert.equal(error.reason, "You don't voted to this category")
      })
  })

  it("when a user unvoted with success should remove votes/tokens from voted mapping", async () => {
    await addCategory("Solo 1");

    await instance.vote(1, "100000000000000000000");
    const unvote = await instance.unvote(1);
    const voted = await instance.voted(msgSender, 1)

    assert.equal(voted, 0);
  })

  it("when a user unvoted with success should remove votes/tokens from category", async () => {
    await addCategory("Solo 1");

    await instance.vote(1, "100000000000000000000");
    await instance.unvote(1);
    const votes = await instance.votes(1);

    assert.equal(votes, 0);
  })

  it("when a user unvoted in a category your tokens should allowed back", async () => {
    await addCategory("Solo 1");
    await addCategory("Solo 2");

    await transferTokensTo(user1Address, "50000000000000000000000");

    await instance.vote(1, "1000000000000000000000", { from: user1Address });
    await instance.vote(2, "5000000000000000000000", { from: user1Address });

    await instance.unvote(1, { from: user1Address });

    const allowance = await isaPool.allowance({ from: user1Address });

    assert.equal(allowance, "1000000000000000000000");
  })
})
