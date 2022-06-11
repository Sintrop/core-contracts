const ActivistContract = artifacts.require("ActivistContract");
const UserContract = artifacts.require("UserContract");

contract('ActivistContract', (accounts) => {
  let instance;
  let userContract;
  let [ownerAddress, activ1Address, activ2Address] = accounts;

  const addActivist = async (name, address) => {
    await instance.addActivist(
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

  beforeEach(async () => {
    userContract = await UserContract.new(); 

    instance = await ActivistContract.new(userContract.address);

    await userContract.newAllowedCaller(instance.address);
    await instance.newAllowedCaller(ownerAddress);
  })

  context("when will create new activist (.addActivist)", () => {
    context("when is allowed", () => {

      context("when activist exists", () => {
        it("should return error", async () => {
          await addActivist("Activist A", activ1Address);
      
          await addActivist("Activist A", activ1Address)
            .then(assert.fail)
            .catch((error) => {
              assert.equal(error.reason, "This activist already exist")
            })
        })
      })

      context("when activist don't exists", () => {
        it("should create activist", async () => {
          await addActivist("Activist A", activ1Address);
          await addActivist("Activist B", activ2Address);
          const activist = await instance.getActivist(activ1Address);
      
          assert.equal(activist.activistWallet, activ1Address);
        })

        it("should be created with totalInspections equal zero", async () => {
          await addActivist("Activist A", activ1Address);
      
          const activist = await instance.getActivist(activ1Address);
      
          assert.equal(activist.totalInspections, 0);
        })

        it("should be created with recentInspection equal false", async () => {
          await addActivist("Activist A", activ1Address);
      
          const activist = await instance.getActivist(activ1Address);
      
          assert.equal(activist.recentInspection, false);
        })

        it("should increment activistsCount after create activist", async () => {
          await addActivist("Activist A", activ1Address);
          await addActivist("Activist B", activ2Address);
          const activistsCount = await instance.activistsCount();
      
          assert.equal(activistsCount, 2);
        })

        it("should add created activist in activistList (array)", async () => {
          await addActivist("Activist A", activ1Address);
          await addActivist("Activist B", activ2Address);
      
          const activists = await instance.getActivists();
      
          assert.equal(activists[0].activistWallet, activ1Address);
        })

        it("should add created activist in userType contract as a ACTIVIST", async () => {
          await addActivist("Activist A", activ1Address);
      
          const userType = await userContract.getUser(activ1Address);
          const ACTIVIST = 1
      
          assert.equal(userType, ACTIVIST);
        })
      })
    })
  })

  context("when will get activists (.getActivists)", () => {

    it("should return activists when has activists", async () => {
      await addActivist("Activist A", activ1Address);
      await addActivist("Activist B", activ2Address);
  
      const activists = await instance.getActivists();
  
      assert.equal(activists.length, 2);
    })

    it("should return activists equal zero when dont has it", async () => {
      const activists = await instance.getActivists();
  
      assert.equal(activists.length, 0);
    })

  })

  context("when will get activist (.getActivist)", () => {
    it("should return a activist", async () => {
      await addActivist("Activist A", activ1Address);
  
      const activist = await instance.getActivist(activ1Address);
  
      assert.equal(activist.activistWallet, activ1Address);
    })
  })

  context("when will check if activist exists", () => {
    it("should return true when exists", async () => {
      await addActivist("Activist A", activ1Address);
      const activistExists = await instance.activistExists(activ1Address);
  
      assert.equal(activistExists, true);
    })

    // Todo Add when not exists
  })

  context("when will update recentInspection (.recentInspection)", () => {
    context("with allowed caller", () => {
      it("should update", async () => {
        await addActivist("Activist A", activ1Address);
        await instance.recentInspection(activ1Address, true);
    
        const activist = await instance.getActivist(activ1Address);
    
        assert.equal(activist.recentInspection, true);
      })
    })

    context("with don't allowed caller", () => {
      it("should return error", async () => {
        await addActivist("Activist A", activ1Address);
        await instance.recentInspection(activ1Address, true, { from: activ1Address })
          .then(assert.fail)
          .catch((error) => {
            assert.equal(error.reason, "Not allowed caller")
          })
      })
    })
  })

  context("when will update incrementRequests (.incrementRequests)", () => {
    context("with allowed caller", () => {
      it("should success .incrementRequests when is allowed caller", async () => {
        await addActivist("Activist A", activ1Address);
        await instance.incrementRequests(activ1Address);
    
        const activist = await instance.getActivist(activ1Address);
    
        assert.equal(activist.totalInspections, 1);
      })
    })

    context("with don't allowed caller", async () => {
      it("should return error .incrementRequests when is not allowed caller", async () => {
        await addActivist("Activist A", activ1Address);
        await instance.incrementRequests(activ1Address, { from: activ1Address })
          .then(assert.fail)
          .catch((error) => {
            assert.equal(error.reason, "Not allowed caller")
          })
      })
    })
  })
})
