const SatToken = artifacts.require("SatToken");
const DeveloperPool = artifacts.require("DeveloperPool");

advanceBlock = async (blocksNumber) => {
  for(let i = 0; i < blocksNumber; i++) {
    let promise = new Promise((resolve, reject) => {
      web3.currentProvider.send({
        jsonrpc: '2.0',
        method: 'evm_mine',
        id: new Date().getTime()
      }, (err, result) => {
        if (err) { return reject(err) }
        const newBlockHash = web3.eth.getBlock('latest').hash
  
        return resolve(newBlockHash)
      })
    })
  }
}

contract('DeveloperPool', (accounts) => {
    let instance;
    let [ownerAddress, dev1Address, dev2Address] = accounts;
    let args = {
      tokensPerEra: 5000,
      blocksPerEra: 10,
      eraMax: 5
    }

    const addDeveloper = async (address) => {
      await instance.addDeveloper(address);
    }

    const levelsSumEras = async () => {
      const levelsSumEra1 = await instance.levelsSumPerEra(0);
      const levelsSumEra2 = await instance.levelsSumPerEra(1);
      const levelsSumEra3 = await instance.levelsSumPerEra(2);
      const levelsSumEra4 = await instance.levelsSumPerEra(3);
      const levelsSumEra5 = await instance.levelsSumPerEra(4);

      const levelsSum = parseInt(levelsSumEra1) + 
                        parseInt(levelsSumEra2) +
                        parseInt(levelsSumEra3) +
                        parseInt(levelsSumEra4) +
                        parseInt(levelsSumEra5);
      return levelsSum;
    }

    beforeEach(async () => {
      const satToken = await SatToken.new("1500000000000000000000000000");
      instance = await DeveloperPool.new(
        satToken.address, 
        args.tokensPerEra,
        args.blocksPerEra,
        args.eraMax
      )

      satToken.addContractPool(instance.address, "15000000000000000000000000")
    })

    it('should tokenPerEra be equal the deployed value with decimals', async () => {
      const tokensPerEra = await instance.tokensPerEra();
      const tokensPerEraWithdecimals = args.tokensPerEra * 10 ** 18;

      assert.equal(tokensPerEra, tokensPerEraWithdecimals);
    })

    it('should blocksPerEra be equal the deployed value', async () => {
      const blocksPerEra = await instance.blocksPerEra();

      assert.equal(blocksPerEra, args.blocksPerEra);
    })

    it('should eraMax be equal the deployed value', async () => {
      const eraMax = await instance.eraMax();

      assert.equal(eraMax, args.eraMax);
    })

    it('should create developer', async () => {
      await addDeveloper(dev1Address);
      const developersCount = await instance.developersCount();

      assert.equal(developersCount, 1);
    })

    it("should return the developer", async () => {
      await addDeveloper(dev1Address);
      const developer = await instance.getDeveloper(dev1Address);

      assert.equal(developer._address, dev1Address);
    })

    it("should be 1 the initial developer level", async () => {
      await addDeveloper(dev1Address);
      const developer = await instance.getDeveloper(dev1Address);

      assert.equal(developer.level, 1);
    })

    it("should deploy with initial era equal one", async () => {
      const currentContractEra = await instance.currentContractEra();
      assert.equal(currentContractEra, 1);
    })

    it("should increment developer level in one when add new level", async () => {
      await addDeveloper(dev1Address);
      await instance.addLevel(dev1Address);

      const developer = await instance.getDeveloper(dev1Address);

      assert.equal(developer.level, 2);
    })

    it("should create developer with current contract era", async () => {
      await advanceBlock(10)
      await addDeveloper(dev1Address);

      const currentContractEra = await instance.currentContractEra();
      const developer = await instance.getDeveloper(dev1Address);

      assert.equal(developer.currentEra, currentContractEra);
    })

    it("should add +1 level in levelsSumPerEra after add new developer", async () => {
      await addDeveloper(dev1Address);

      const levelsSum = await levelsSumEras();

      assert.equal(levelsSum, 5);
    })

    it(`should add +1 level in levelsSumPerEra just for the era that the
     dev is it forward add new developer`, async () => {
      await addDeveloper(dev1Address);
      await advanceBlock(args.blocksPerEra);
      await addDeveloper(dev2Address);

      const levelsSum = await levelsSumEras();

      assert.equal(levelsSum, 9);
    })

    it("should add +1 level in levelsSumPerEra after add level", async () => {
      await addDeveloper(dev1Address);
      await instance.addLevel(dev1Address);

      const levelsSum = await levelsSumEras();

      assert.equal(levelsSum, 10);
    })

    it(`should add +1 level in levelsSumPerEra just for the era that the
     dev is it forward after add level`, async () => {
      await addDeveloper(dev1Address);
      await advanceBlock(args.blocksPerEra);
      await addDeveloper(dev2Address);
      await instance.addLevel(dev2Address);

      const levelsSum = await levelsSumEras();

      assert.equal(levelsSum, 13);
    })

    it('should returns array of developer address', async () => {
      await addDeveloper(dev1Address);
      const developers = await instance.getDevelopersAddress();

      assert.equal(developers.length, 1);
    })

    it('should return integer greater than zero when cant approve tokens', async () => {
      await addDeveloper(dev1Address)
      const nextApproveTime = await instance.nextApproveTime({ from: dev1Address });

      assert.isAbove(parseInt(nextApproveTime), 0);
    })

    it('should return integer smaller than zero when can approve tokens', async () => {
      await addDeveloper(dev1Address);
      await advanceBlock(args.blocksPerEra);
      const nextApproveTime = await instance.nextApproveTime({ from: dev1Address });

      assert.isBelow(parseInt(nextApproveTime), 1);
    })

    it("should set to zero the developer level when undoLevel", async () => {
      await addDeveloper(dev1Address);
      await instance.addLevel(dev1Address);
      await instance.undoLevel(dev1Address);
      const developer = await instance.getDeveloper(dev1Address);

      assert.equal(developer.level, 0);
    })

    it("should remove the level of the dev from levelsSumPerEra when undoLevel", async () => {
      await addDeveloper(dev1Address);
      await advanceBlock(args.blocksPerEra);
      await addDeveloper(dev2Address);
      await instance.addLevel(dev1Address);
      await instance.undoLevel(dev2Address);

      const levelsSum = await levelsSumEras();

      assert.equal(levelsSum, 10);
    }) 

    it("should return zero when can't allowance from DeveloperPool address", async () => {
      await addDeveloper(dev1Address);

      const allowance = await instance.allowance({ from: dev1Address });

      assert.equal(allowance, 0);
    })

    it("should return zero times to approve when can't approve", async () => {
      await addDeveloper(dev1Address);

      const canApproveTimes = await instance.canApproveTimes({ from: dev1Address });

      assert.equal(canApproveTimes, 0);
    })

    it(`should return integer with fixed point that represent 2 times to approve
     when the dev is in second era and did not approve tokens yet`, async () => {
      await addDeveloper(dev1Address);
      await advanceBlock(args.blocksPerEra * 2);

      const canApproveTimes = await instance.canApproveTimes({ from: dev1Address });
      const blocksPrecision = await instance.blocksPrecision();

      const fixedPoint = canApproveTimes/(10**blocksPrecision)

      assert.equal(Math.ceil(fixedPoint), 2);
    })

    it(`should add amount of approved tokens in eras metrics after approve tokens`, async () => {
      await addDeveloper(dev1Address);
      await addDeveloper(dev2Address);
      await advanceBlock(args.blocksPerEra);
      await instance.approve({ from: dev1Address });

      const era = await instance.eras(1);
      const allowance = await instance.allowance({ from: dev1Address });

      assert.equal(era.tokens.toString(), allowance);
    })

    it(`should add amount of developers who approved tokens in eras metrics after approve tokens`, async () => {
      await addDeveloper(dev1Address);
      await addDeveloper(dev2Address);
      await advanceBlock(args.blocksPerEra);

      await instance.approve({ from: dev1Address });
      await instance.approve({ from: dev2Address });

      const era = await instance.eras(1);

      assert.equal(era.developers.toString(), 2);
    })

    it(`should update the current era that the dev is after approve tokens`, async () => {
      await addDeveloper(dev1Address);
      await advanceBlock(args.blocksPerEra);

      const developer = await instance.getDeveloper(dev1Address);
      await instance.approve({ from: dev1Address });

      const era = await instance.eras(1);

      assert.equal(era.era.toString(), developer.currentEra);
    })

    it("shoud approve tokens proportional to the level 2 when the total of levels in era is 3", async () => {
      await addDeveloper(dev1Address);
      await addDeveloper(dev2Address);
      await instance.addLevel(dev1Address);
      await advanceBlock(args.blocksPerEra);

      await instance.approve({ from: dev1Address });
      const allowance = await instance.allowance({ from: dev1Address });

      assert.equal(allowance, "3333333333333333333332");
    })

    it("should approve tokens past eras the dev hasn't approved yet", async () => {
      await addDeveloper(dev1Address);
      await addDeveloper(dev2Address);
      await instance.addLevel(dev1Address);
      await advanceBlock(args.blocksPerEra * 3);

      await instance.approve({ from: dev1Address });
      const developer = await instance.getDeveloper(dev1Address);

      assert.equal(developer.currentEra, 4);
    })

    it("should not approve when the dev is in the eraMax of the contract", async () => {
      await addDeveloper(dev1Address);
      await advanceBlock(args.blocksPerEra * 10);

      await instance.approve({ from: dev1Address });
      const developer = await instance.getDeveloper(dev1Address);

      assert.equal(developer.currentEra, 6);
    })

    it("should increment era of the dev in 1 when approve tokens", async () => {
      await addDeveloper(dev1Address);
      await advanceBlock(args.blocksPerEra);
      await instance.approve({ from: dev1Address });
      const developer = await instance.getDeveloper(dev1Address);

      assert.equal(developer.currentEra, 2);
    })

    it("should return error when the dev try approve tokens and can't yet", async () => {
      await addDeveloper(dev1Address);
      instance.approve({ from: dev1Address })
      .then(assert.fail)
      .catch(function(error) {
        assert.equal(error.message, "You can't withdraw yet")
      })
    })
})
