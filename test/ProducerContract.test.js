const ProducerContract = artifacts.require("ProducerContract");

contract('ProducerContract', (accounts) => {
  let instance;
  let [ownerAddress, prod1Address, prod2Address] = accounts;

  const addProducer = async (name, address) => {
    await instance.addProducer(
      name,
      "111.111.111-00",
      "CPF",
      "Brazil",
      "SP",
      "Jundiai",
      "135465-005",
      {from: address}
    )
  }

  beforeEach(async () => {
    instance = await ProducerContract.new();
  })

  it("should create producer", async () => {
    await addProducer("Producer A", prod1Address);
    await addProducer("Producer B", prod2Address);
    const producer = await instance.getProducer(prod1Address);

    assert.equal(producer.producer_wallet, prod1Address);
  })

  it("should return error when try create same producer", async () => {
    await addProducer("Producer A", prod1Address);

    addProducer("Producer A", prod1Address)
    .then(assert.fail)
    .catch((error) => {
      assert.equal(error.reason, "This producer already exist")
    })
  })

  it("should return false when producer don't exists", async () => {
    const producerExists = await instance.producerExists(prod1Address);

    assert.equal(producerExists, false);
  })

  it("should be created with totalRequest equal zero", async () => {
    await addProducer("Producer A", prod1Address);

    const producer = await instance.getProducer(prod1Address);

    assert.equal(producer.totalRequests, 0);
  })

  it("should be created with isaPoints equal zero", async () => {
    await addProducer("Producer A", prod1Address);

    const producer = await instance.getProducer(prod1Address);

    assert.equal(producer.isaPoints, 0);
  })

  it("should return zero when can't allowed tokens", async () => {
    await addProducer("Producer A", prod1Address);

    const tokensApprove = await instance.getProducerApprove(prod1Address);

    assert.equal(tokensApprove, 0);
  })

  it("should increment producersCount after create producer", async () => {
    await addProducer("Producer A", prod1Address);
    await addProducer("Producer B", prod2Address);
    const producersCount = await instance.producersCount();

    assert.equal(producersCount, 2);
  })

  it("should add created producer in producerList (array)", async () => {
    await addProducer("Producer A", prod1Address);
    await addProducer("Producer A", prod2Address);

    const producers = await instance.getProducers();

    assert.equal(producers[0].producer_wallet, prod1Address);
  })

  it("should add created producer in userType contract as a PRODUCER", async () => {
    await addProducer("Producer A", prod1Address);

    const userType = await instance.getUser(prod1Address);
    const PRODUCER = 1

    assert.equal(userType, PRODUCER);
  })

  it("should return a producer", async () => {
    await addProducer("Producer A", prod1Address);

    const producer = await instance.getProducer(prod1Address);

    assert.equal(producer.producer_wallet, prod1Address);
  })
})