const Sintrop = artifacts.require("Sintrop");
const CategoryContract = artifacts.require("CategoryContract");
const IsaPool = artifacts.require("IsaPool");
const SacToken = artifacts.require("SacToken");
const UserContract = artifacts.require("UserContract");
const ActivistContract = artifacts.require("ActivistContract");
const ProducerContract = artifacts.require("ProducerContract");

contract('Sintrop', (accounts) => {
  let instance;
  let userContract;
  let activistContract;
  let producerContract;
  let [ownerAddress, producerAddress, producer2Address, activistAddress, activist2Address] = accounts;
  const STATUS = {
    open: 0,
    expired: 1,
    inspected: 2,
    accepted: 3
  }

  const addProducer = async (name, address) => {
    await producerContract.addProducer(
      name,
      "111.111.111-00",
      "CPF",
      "Brazil",
      "SP",
      "Jundiai",
      "135465-005",
      { from: address }
    )
  }

  const addActivist = async (name, address) => {
    await activistContract.addActivist(
      name,
      "111.111.111-00",
      "CPF",
      "Brazil",
      "SP",
      "Jundiai",
      "135465-005",
      { from: address }
    )
  }

  const addCategory = async (name) => {
    await categoryContract.addCategory(
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
    userContract = await UserContract.new();

    producerContract = await ProducerContract.new(userContract.address);
    activistContract = await ActivistContract.new(userContract.address);

    sacToken = await SacToken.new("1500000000000000000000000000");
    isaPool = await IsaPool.new(sacToken.address);

    categoryContract = await CategoryContract.new(isaPool.address);
    instance = await Sintrop.new(activistContract.address, producerContract.address);

    await userContract.newAllowedCaller(activistContract.address)
    await userContract.newAllowedCaller(producerContract.address)
    await activistContract.newAllowedCaller(instance.address)
    await producerContract.newAllowedCaller(instance.address)
    

    await addProducer("Producer A", producerAddress);
    await addActivist("Activist A", activistAddress);
  })

  it("should request inspection when is producer and don't has request OPEN or ACCEPTED", async () => {
    await instance.requestInspection({ from: producerAddress });
    const inspection = await instance.getInspection(1);

    assert.equal(inspection.producerWallet, producerAddress);
  })

  it("should return message error when is not an producer and try request inspection", async () => {
    await instance.requestInspection()
      .then(assert.fail)
      .catch((error) => {
        assert.equal(error.reason, "Please register as producer")
      })
  })

  it("should return message error when has inspection OPEN o ACCEPTED and try request inspection", async () => {
    await instance.requestInspection({ from: producerAddress })
    await instance.requestInspection({ from: producerAddress })
      .then(assert.fail)
      .catch((error) => {
        assert.equal(error.reason, "Request OPEN or ACCEPTED")
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

  it("should create request inspection with initial isas equal empty array", async () => {
    await instance.requestInspection({ from: producerAddress });
    const inspection = await instance.getInspection(1);

    assert.equal(inspection.isas.length, 0);
  })

  it("should increment total of inspection after create new inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    const inspectionsCount = await instance.inspectionsCount()

    assert.equal(inspectionsCount, 1);
  })

  it("should set to true producer recentInspection when request inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    const producer = await producerContract.getProducer(producerAddress);

    assert.equal(producer.recentInspection, true);
  })

  it("should return inspections when call getInspections and has it", async () => {
    await instance.requestInspection({ from: producerAddress });

    const inspectionsList = await instance.getInspections();

    assert.equal(inspectionsList.length, 1)
  })

  it("should return zero inspections when call getInspections and dont has it", async () => {
    const inspectionsList = await instance.getInspections();
    assert.equal(inspectionsList.length, 0)
  })

  it("should be same inspection in array of mapping when call getInspections and dont has it", async () => {
    await addProducer("Producer B", producer2Address);

    await instance.requestInspection({ from: producerAddress });
    await instance.requestInspection({ from: producer2Address });

    const inspectionsList = await instance.getInspections();
    const inspection1 = await instance.getInspection(1);
    const inspection2 = await instance.getInspection(2);

    assert.equal(inspectionsList[0].id, inspection1.id);
    assert.equal(inspectionsList[1].id, inspection2.id);
  })

  it("should accept inspection with success when is OPEN and is Activist", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    const inspection = await instance.getInspection(1);

    assert.equal(inspection.status, STATUS.accepted);
  })

  it("should set address of activist after accept inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    const inspection = await instance.getInspection(1);

    assert.equal(inspection.activistWallet, activistAddress);
  })

  it("should set activist recentInspection to true after accept inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    const activist = await activistContract.getActivist(activistAddress);

    assert.equal(activist.recentInspection, true);
  })

  it("should return error message when is not activist and try accepet inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: producerAddress })
      .then(assert.fail)
      .catch((error) => {
        assert.equal(error.reason, "Please register as activist")
      })
  })

  it("should return error message when inspection don't exists and try accept", async () => {
    await instance.acceptInspection(1, { from: activistAddress })
      .then(assert.fail)
      .catch((error) => {
        assert.equal(error.reason, "This inspection don't exists")
      })
  })

  it("should return error message when inspection is not OPEN and try accept", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await instance.acceptInspection(1, { from: activistAddress })
      .then(assert.fail)
      .catch((error) => {
        assert.equal(error.reason, "This inspection is not OPEN")
      })
  })

  it("should realize Inspection when is activist owner to a accepted inspection and try realize", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addCategory("Solo A");
    await addCategory("Solo B");
    await addCategory("Solo C");

    const isas = [[1, 0], [2, 0], [3, 1]];
    await instance.realizeInspection(1, isas, { from: activistAddress });

    const inspection = await instance.getInspection(1);

    assert.equal(inspection.status, STATUS.inspected);
  })

  it("should return error message when inspection is not accepted and try realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });

    await instance.realizeInspection(1, [], { from: activistAddress })
      .then(assert.fail)
      .catch((error) => {
        assert.equal(error.reason, "Accept this inspection before")
      })
  })

  it("should return error message when is not inspection owner and try realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addActivist("Activist B", activist2Address);

    await instance.realizeInspection(1, [], { from: activist2Address })
      .then(assert.fail)
      .catch((error) => {
        assert.equal(error.reason, "You not accepted this inspection")
      })
  })

  it("should return error message when is not activist and try realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await instance.realizeInspection(1, [], { from: producerAddress })
      .then(assert.fail)
      .catch((error) => {
        assert.equal(error.reason, "Please register as activist")
      })
  })

  it("should return error message when inspection don't exists and try realize inspection", async () => {
    await instance.realizeInspection(1, [], { from: activistAddress })
      .then(assert.fail)
      .catch((error) => {
        assert.equal(error.reason, "This inspection don't exists")
      })
  })

  it("should update inspectionList when realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addCategory("Solo A");
    await addCategory("Solo B");
    await addCategory("Solo C");

    const isas = [[1, 0], [2, 0], [3, 1]];
    await instance.realizeInspection(1, isas, { from: activistAddress });

    const inspections = await instance.getInspections();

    assert.equal(inspections[0].status, STATUS.inspected);
  })

  it("should update inspection isas after realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addCategory("Solo A");
    await addCategory("Solo B");
    await addCategory("Solo C");

    const isas = [[1, 0], [2, 0], [3, 1]];
    await instance.realizeInspection(1, isas, { from: activistAddress });

    const inspection = await instance.getInspection(1);

    assert.equal(inspection.isas.length, isas.length);
  })

  it("should add 10 isaPoints when select totallySustainable after realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addCategory("Solo A");

    const isas = [[1, 0]];
    await instance.realizeInspection(1, isas, { from: activistAddress });

    const inspection = await instance.getInspection(1);

    assert.equal(inspection.isaPoints, 10);
  })

  it("should add 5 isaPoints when select partiallySustainable after realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addCategory("Solo A");

    const isas = [[1, 1]];
    await instance.realizeInspection(1, isas, { from: activistAddress });

    const inspection = await instance.getInspection(1);

    assert.equal(inspection.isaPoints, 5);
  })

  it("should add 0 isaPoints when select neutro after realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addCategory("Solo A");

    const isas = [[1, 2]];
    await instance.realizeInspection(1, isas, { from: activistAddress });

    const inspection = await instance.getInspection(1);

    assert.equal(inspection.isaPoints, 0);
  })

  it("should remove 5 isaPoints when select partiallyNotSustainable after realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addCategory("Solo A");

    const isas = [[1, 3]];
    await instance.realizeInspection(1, isas, { from: activistAddress });

    const inspection = await instance.getInspection(1);

    assert.equal(inspection.isaPoints, -5);
  })

  it("should remove 10 isaPoints when select totallyNotSustainable after realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addCategory("Solo A");

    const isas = [[1, 4]];
    await instance.realizeInspection(1, isas, { from: activistAddress });

    const inspection = await instance.getInspection(1);

    assert.equal(inspection.isaPoints, -10);
  })

  it("should add isaPoints in producer after realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addCategory("Solo A");

    const isas = [[1, 4]];
    await instance.realizeInspection(1, isas, { from: activistAddress });

    const inspection = await instance.getInspection(1);
    const producer = await producerContract.getProducer(producerAddress);

    assert.equal(inspection.isaPoints, producer.isaPoints);
  })

  it("should calc isa points and update inspection isaPoints after realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addCategory("Solo A");
    await addCategory("Solo B");
    await addCategory("Solo C");

    const isas = [[1, 0], [2, 0], [3, 1]];
    await instance.realizeInspection(1, isas, { from: activistAddress });

    const inspection = await instance.getInspection(1);

    assert.equal(inspection.isaPoints, 25);
  })

  it("should set producer recentInspection to false after realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addCategory("Solo A");

    const isas = [[1, 0]];
    await instance.realizeInspection(1, isas, { from: activistAddress });

    const producer = await producerContract.getProducer(producerAddress);

    assert.equal(producer.recentInspection, false);
  })

  it("should set activist recentInspection to false after realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addCategory("Solo A");

    const isas = [[1, 0]];
    await instance.realizeInspection(1, isas, { from: activistAddress });

    const activist = await activistContract.getActivist(activistAddress);

    assert.equal(activist.recentInspection, false);
  })

  it("should increment producer totalRequests after realized inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addCategory("Solo A");

    const isas = [[1, 0]];
    await instance.realizeInspection(1, isas, { from: activistAddress });

    const producer = await producerContract.getProducer(producerAddress);

    assert.equal(producer.totalRequests, 1);
  })

  it("should increment activist totalInspections after realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addCategory("Solo A");

    const isas = [[1, 0]];
    await instance.realizeInspection(1, isas, { from: activistAddress });

    const activist = await activistContract.getActivist(activistAddress);

    assert.equal(activist.totalInspections, 1);
  })

  it("should add inspection to activist in userInspections after realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addCategory("Solo A");

    const isas = [[1, 0]];
    await instance.realizeInspection(1, isas, { from: activistAddress });

    const userInspections = await instance.getInspectionsHistory({ from: activistAddress });

    assert.equal(userInspections.length, 1);
  })

  it("should add inspection to producer in userInspections after realize inspection", async () => {
    await instance.requestInspection({ from: producerAddress });
    await instance.acceptInspection(1, { from: activistAddress });

    await addCategory("Solo A");

    const isas = [[1, 0]];
    await instance.realizeInspection(1, isas, { from: activistAddress });

    const userInspections = await instance.getInspectionsHistory({ from: producerAddress });

    assert.equal(userInspections.length, 1);
  })
})
