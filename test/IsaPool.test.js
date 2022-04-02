const IsaPool = artifacts.require("IsaPool");
const SatToken = artifacts.require("SatToken");

contract('IsaPool', (accounts) => {
    let instance;
    let satToken;
    let [owner, user1Address, user2Address] = accounts;

    const transferTokensTo = async (userAddress, tokens) => {
        await satToken.transfer(userAddress, tokens);
    }

    beforeEach(async () => {
        satToken = await SatToken.new("1500000000000000000000000000");

        instance = await IsaPool.new(satToken.address);

        await satToken.addContractPool(instance.address, "15000000000000000000000000");
        await transferTokensTo(user1Address, "500000000000000000000000");
    })

    it("when call allowance should return how much token the user has approved from this pool", async () => {
        await instance.changeAllowedCaller(user2Address);
        const allowance = await instance.allowance({ from: user1Address });
        await instance.approveWith(user2Address, "1500000000000000000000", { from: user2Address });
        const allowance2 = await instance.allowance({ from: user2Address });

        assert.equal(allowance, 0);
        assert.equal(allowance2, 1500000000000000000000);
    });

    it("when call balanceOf should return how much SAC Tokens the account has", async () => {
        const balanceOf = await instance.balanceOf(owner);
        const balanceOf2 = await instance.balanceOf(instance.address);
        const balanceOf3 = await instance.balanceOf(user1Address);
        const balanceOf4 = await instance.balanceOf(user2Address);

        assert.equal(balanceOf, "1484500000000000000000000000");
        assert.equal(balanceOf2, "15000000000000000000000000");
        assert.equal(balanceOf3, "500000000000000000000000");
        assert.equal(balanceOf4, "0");
    })

    it("when call balance should return how much SAC Tokens the pool has", async () => {
        const balance = await instance.balance();

        assert.equal(balance, "15000000000000000000000000");
    })

    it("when call transferWith and dont is a contract pool should return error message", async () => {
        await satToken.removeContractPool(instance.address);
        await instance.transferWith(user2Address, "1000000000000000000000")
            .then(assert.fail)
            .catch((error) => {
                assert.equal(error.reason, "Not a contract pool");
            })
    });

    it("when call transferWith and dont has tokens should return error message", async () => {
        await instance.transferWith(user2Address, "1000000000000000000000")
            .then(assert.fail)
            .catch((error) => {
                assert.equal(error.reason, "You don't has SAC Tokens");
            })
    });

    it("when call transferWith and has tokens should transfer some tokens to contract pool address", async () => {
        await instance.transferWith(user1Address, "1000000000000000000000");

        const balance = await instance.balance();
        const balanceOf = await instance.balanceOf(user1Address);

        assert.equal(balance, "15001000000000000000000000");
        assert.equal(balanceOf, "499000000000000000000000");
    });

    it("when call approve should return error message when is not a allowed caller", async () => {
        await instance.approveWith(owner, 0)
            .then(assert.fail)
            .catch((error) => {
                assert.equal(error.reason, "Not allowed caller");
            })
    });

    it("when call approve should return error message when is not a contract pool", async () => {
        await instance.changeAllowedCaller(owner);
        await satToken.removeContractPool(instance.address);
        await instance.approveWith(owner, 0)
            .then(assert.fail)
            .catch((error) => {
                assert.equal(error.reason, "Not a contract pool");
            })
    });

    it("should approve tokens when approve is called by allowed caller and is a contract pool", async () => {
        await instance.changeAllowedCaller(owner);
        await instance.approveWith(owner, "500000000000000000000");

        const allowance = await instance.allowance();

        assert.equal(allowance, "500000000000000000000");
    });
});