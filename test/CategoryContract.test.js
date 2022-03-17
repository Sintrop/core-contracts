const CategoryContract = artifacts.require("CategoryContract");

contract('CategoryContract', (accounts) => {
  let instance;
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

  beforeEach(async () => {
    instance = await CategoryContract.new();
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

  it("should increment vote in 1 when call vote function", async () => {
    await addCategory("Solo");
    await instance.vote(1, 0);

    const category = await instance.categories(1);

    assert.equal(category.votesCount, 1);
  })

  it("should vote and send tokens only to the passed id", async () => {
    await addCategory("Solo");
    await instance.vote(1, 100);

    const votes1 = await instance.votes(1);
    const votes2 = await instance.votes(2);

    assert.equal(votes1, 100);
    assert.equal(votes2, 0);
  })

  it("should increment 100 tokens when call vote function and send 100 tokens", async () => {
    await addCategory("Solo");
    await instance.vote(1, 100);

    const votes = await instance.votes(1);

    assert.equal(votes, 100);
  })

  it("should have 150 tokens when call vote function and send 100 tokens and already have 50 tokens", async () => {
    await addCategory("Solo");
    await instance.vote(1, 50);
    await instance.vote(1, 100);

    const votes = await instance.votes(1);

    assert.equal(votes, 150);
  })

  it("should increment 0 tokens when call vote function and dont send tokens", async () => {
    await addCategory("Solo");
    await instance.vote(1, 0);

    const votes = await instance.votes(1);

    assert.equal(votes, 0);
  })

  it("should set amount of tokens that the user voted to category id when vote", async () => {
    await addCategory("Solo 1");
    await addCategory("Solo 2");
    await instance.vote(1, 100);
    await instance.vote(2, 50);

    const votes1 = await instance.voted(msgSender, 1);
    const votes2 = await instance.voted(msgSender, 2);
    const votes3 = await instance.voted(msgSender, 3);

    assert.equal(votes1, 100);
    assert.equal(votes2, 50);
    assert.equal(votes3, 0);
  })

  it("should start with voted zero categories", async () => {
    await addCategory("Solo 1");
    await addCategory("Solo 2");

    const votes1 = await instance.voted(msgSender, 1);
    const votes2 = await instance.voted(msgSender, 0);

    assert.equal(votes1, 0);
    assert.equal(votes2, 0);
  })

  it("should increment vote of users in same category", async () => {
    await addCategory("Solo 1");

    await instance.vote(1, 100, { from: user1Address });
    await instance.vote(1, 100, { from: user2Address });

    const votes = await instance.votes(1);

    assert.equal(votes, 200);
  })

  it("when more than one user voted in one category each user must have your tokens part", async () => {
    await addCategory("Solo 1");

    await instance.vote(1, 100, { from: user1Address });
    await instance.vote(1, 100, { from: user2Address });

    const votes1 = await instance.voted(user1Address, 1);
    const votes2 = await instance.voted(user2Address, 1);

    assert.equal(votes1, 100);
    assert.equal(votes2, 100);
  })

  it("when user try unvote and category dont exists should return error message", async () => {
    await instance.unvote(1)
    .then(assert.fail)
    .catch((error) => {
      assert.equal(error.reason, "This category don't exists")
    })
  })   
  
  it("should return zero tokens when user unvote in a category he didn't vote for", async () => {
    await addCategory("Solo 1");

    const unvote = await instance.unvote.call(1);

    assert.equal(unvote, 0);
  })  

  it("dont should remove votes when user try unvote and dont voted yet", async () => {
    await addCategory("Solo 1");

    await instance.vote(1, 100);

    const unvote = await instance.unvote.call(1, { from: user1Address });
    const votes = await instance.votes(1);

    assert.equal(unvote, 0);
    assert.equal(votes, 100);
  }) 

  it("should return 100 tokens when user unvote and already voted with 100 tokens", async () => {
    await addCategory("Solo 1");

    await instance.vote(1, 100);
    const unvote = await instance.unvote.call(1);

    assert.equal(unvote, 100);
  })

  it("when a user unvoted with success should remove votes from category and from user voted mapping", async () => {
    await addCategory("Solo 1");

    await instance.vote(1, 5000);
    await instance.vote(1, 150, { from: user1Address });

    await instance.unvote(1);
    const votes = await instance.votes(1);
    const voted = await instance.voted(msgSender, 1)

    assert.equal(votes, 150);
    assert.equal(voted, 0);
  })
})
