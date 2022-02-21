const CategoryContract = artifacts.require("CategoryContract");

contract('CategoryContract', (accounts) => {
  let instance;
  let [msgSender] = accounts;

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

  it("should add correct index of created category", async () => {
    await addCategory("Solo");
    await addCategory("Solo 2");
    await addCategory("Solo 3");
    await addCategory("Solo 4");

    const categories = await instance.getCategories();

    assert.equal(categories[2].index, 2)
  })

  it("should increment total of categories after a new is added", async () => {
    await addCategory("Solo");
    await addCategory("Solo 2");
    const categoryCounts = await instance.categoryCounts();

    assert.equal(categoryCounts, 2)
  })

  it("should add category in category list after create", async () => {
    await addCategory("Solo");
    const categories = await instance.getCategories();

    assert.equal(categories.length, 1)
  })

  it("should add same category in mapping and array position based on index attr", async () => {
    await addCategory("Solo");
    await addCategory("Solo 2");
    const categoriesList = await instance.getCategories();
    const category = await instance.categories(2);

    assert.equal(categoriesList[1].index, category.index)
  })

  it("should create category with votes equal 0", async () => {
    await addCategory("Solo");
    const categories = await instance.getCategories();

    assert.equal(parseInt(categories[0].votesCount), 0)
  })

  it("should increment vote in 1 when call vote function", async () => {
    await addCategory("Solo");
    await instance.vote(1);

    const category = await instance.categories(1);

    assert.equal(category.votesCount, 1);
  })
})
