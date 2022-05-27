const Blockable = artifacts.require("Blockable");

contract('Blockable', (accounts) => {
  let instance;
  let [owner, user1Address, user2Address] = accounts;

  const params = {
    blocksPerEra: 10,
    eraMax: 12
  }

  advanceBlock = async (blocksNumber) => {
    for (let i = 0; i < blocksNumber; i++) {
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


  beforeEach(async () => {
    instance = await Blockable.new(params.blocksPerEra, params.eraMax);
  })

  context("when deploy", () => {
    it("should have correct blocksPerEra", async () => {
      const blocksPerEra = await instance.blocksPerEra();

      assert.equal(blocksPerEra, params.blocksPerEra);
    })

    it("should have correct eraMax", async () => {
      const eraMax = await instance.eraMax();

      assert.equal(eraMax, params.eraMax);
    })

    it("should have deployedAt state", async () => {
      const deployedAt = await instance.deployedAt();

      expect(parseInt(deployedAt)).to.be.greaterThan(0);
    })
  })

  context("when call currentContractEra", () => {
    context("when don't have passed eras", () => {
      it("should return that be in era 1", async () => {
        const currentContractEra = await instance.currentContractEra();

        assert.equal(currentContractEra, 1);
      })
    })

    context("when have passed 1x the blocksPerEra", () => {
      beforeEach(async () => {
        await advanceBlock(params.blocksPerEra)
      })

      it("should return that be in era 2", async () => {
        const currentContractEra = await instance.currentContractEra();
        assert.equal(currentContractEra, 2);
      })
    })

    context("when have passed 5x the blocksPerEra", () => {
      beforeEach(async () => {
        await advanceBlock(5 * params.blocksPerEra)
      })

      it("should return that be in era 6", async () => {
        const currentContractEra = await instance.currentContractEra();
        assert.equal(currentContractEra, 6);
      })
    })
  })

  context("when call canApproveTimes", () => {
    context("when currentContractEra is 1 and currentUserEra is 1", () => {
      const currentUserEra = 1;

      it("should can aprove zero times", async () => {
        const canApproveTimes = await instance.canApproveTimes(currentUserEra);
        assert.equal(canApproveTimes, 0);
      })
    })

    context("when currentContractEra is 3 and currentUserEra is 1", () => {
      beforeEach(async () => {
        await advanceBlock(3 * params.blocksPerEra)
      })

      const currentUserEra = 1;

      it("should can aprove two times", async () => {
        let canApproveTimes = await instance.canApproveTimes(currentUserEra);
        const blocksPrecision = await instance.BLOCKS_PRECISION();
        canApproveTimes = canApproveTimes / (10 ** blocksPrecision)

        assert.equal(canApproveTimes, 2);
      })
    })

    context("when currentContractEra is 10 and currentUserEra is 1", () => {
      beforeEach(async () => {
        await advanceBlock(10 * params.blocksPerEra)
      })

      const currentUserEra = 1;

      it("should can aprove two times", async () => {
        let canApproveTimes = await instance.canApproveTimes(currentUserEra);
        const blocksPrecision = await instance.BLOCKS_PRECISION();
        canApproveTimes = canApproveTimes / (10 ** blocksPrecision)

        assert.equal(canApproveTimes, 9);
      })
    })

    context("when currentContractEra is 4 and currentUserEra is 2", () => {
      beforeEach(async () => {
        await advanceBlock(4 * params.blocksPerEra)
      })

      const currentUserEra = 2;

      it("should can aprove one time", async () => {
        let canApproveTimes = await instance.canApproveTimes(currentUserEra);
        const blocksPrecision = await instance.BLOCKS_PRECISION();
        canApproveTimes = canApproveTimes / (10 ** blocksPrecision)

        assert.equal(canApproveTimes, 2);
      })
    })
  })

  context("when call nextApproveIn", () => {
    context("when user can approve", () => {
      beforeEach(async () => {
        await advanceBlock(2 * params.blocksPerEra)
      })

      const currentUserEra = 1;

      it("should return negative blocks number", async () => {     
        const nextApproveIn = await instance.nextApproveIn(currentUserEra);
        assert.isBelow(parseInt(nextApproveIn), 0)
      })
    })

    context("when user can't approve", () => {
      const currentUserEra = 1;

      it("should return positive blocks number", async () => {     
        const nextApproveIn = await instance.nextApproveIn(currentUserEra);
        assert.isAbove(parseInt(nextApproveIn), 0)
      })
    })
  })

  context("when call canApprove", () => {
    context("when currentUserEra is less than currentContractEra and currentUserEra don't have passed eraMax", () => {
      beforeEach(async () => {
        await advanceBlock(5 * params.blocksPerEra)
      })

      const currentUserEra = 1;

      it("should return true", async () => {
        const canApprove = await instance.canApprove(currentUserEra);
        assert.equal(canApprove, true)
      })
    })

    context("when currentUserEra is less than currentContractEra and currentUserEra have passed eraMax", () => {
      beforeEach(async () => {
        await advanceBlock(20 * params.blocksPerEra)
      })

      const currentUserEra = params.eraMax + 1;

      it("should return false", async () => {
        const canApprove = await instance.canApprove(currentUserEra);
        assert.equal(canApprove, false)
      })
    })

    context("when currentUserEra is equal currentContractEra", () => {
      const currentUserEra = 1;

      it("should return false", async () => {
        const canApprove = await instance.canApprove(currentUserEra);
        assert.equal(canApprove, false)
      })
    })
  })
})
