const Sintrop = artifacts.require("Sintrop");

contract('Sintrop', (accounts) => {
  let instance;
  let [ownerAddress, producerAddress, activistAddress] = accounts;
  const STATUS = {
    open: 0,
    expired: 1,
    inspected: 2,
    accepted: 3
  }

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

  const addActivist = async (name, address) => {
    await instance.addActivist(
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
    instance = await Sintrop.new();
    await addProducer("Producer A", producerAddress);
    await addActivist("Activist A", activistAddress);
  })

  it("should request inspection when is producer and don't has request OPEN", async () => {
    await instance.requestInspection({ from: producerAddress });
    const inspection = await instance.getInspection(1);

    assert.equal(inspection.producerWallet, producerAddress);
  })

  it("should return message error when is not an producer", async () => {
    await instance.requestInspection()
    .then(assert.fail)
    .catch((error) => {
      assert.equal(error.reason, "Please register as producer")
    })
  })

  it("should return message error when has inspection OPEN o ACCEPTED", async () => {
    await instance.requestInspection({ from: producerAddress })
    await instance.requestInspection({ from: producerAddress })
    .then(assert.fail)
    .catch((error) => {
      assert.equal(error.reason, "You have a inspection request OPEN or ACCEPTED")
    })
  })

  it("should create request inspection with initial status equal OPEN", async () => {
    await instance.requestInspection({ from: producerAddress });
    const inspection = await instance.getInspection(1);

    assert.equal(inspection.status, STATUS.open);
  })

  it("should create request inspection with initial isaPoints equal zero", async () => {
    await instance.requestInspection({ from: producerAddress });
    const inspection = await instance.getInspection(1);

    assert.equal(inspection.isaPoints, 0);
  })

  it("should return inspection when exists", async () => {
    await instance.requestInspection({ from: producerAddress });
    const inspection = await instance.getInspection(1);

    assert.equal(inspection.id, 1);
  })


  it("should create request inspection with initial isas equal empty arrayo", async () => {
    await instance.requestInspection({ from: producerAddress });
    const inspection = await instance.getInspection(1);

    assert.equal(inspection.isas.length, 0);
  })

  it("should increment total of inspection after create new inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    const inspectionsCount = await instance.inspectionsCount()

    assert.equal(inspectionsCount, 1);
  })

  it("should set to true producer recentInspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    const producer = await instance.getProducer(producerAddress);

    assert.equal(producer.recentInspection, true);
  })

  it("should add inspection in inspectionList after create new inspection", async () => {
    await instance.requestInspection({ from: producerAddress });

    const inspectionsList = await instance.getInspections();
    const inspection = await instance.getInspection(1);

    assert.equal(inspectionsList[0].index, inspection.index)
  })

})
