const StarNotary = artifacts.require('StarNotary')

contract('StarNotary', accounts => { 

    beforeEach(async function() { 
        this.contract = await StarNotary.new({from: accounts[0]})
    })
    
    describe('can create a star', () => {
        it('can create a star and get its name', async function () { 
            
            await this.contract.createStar('awesome star!', 'dec1', 'mag1', 'cent1', 'story1', 1, {from: accounts[0]})
            assert.equal((await this.contract.tokenIdToStarInfo(1))[0], 'awesome star!')
        })

        it('can get the star owner', async function () {
            await this.contract.createStar('awesome star!', 'dec1', 'mag1', 'cent1', 'story1', 1, {from: accounts[0]})
            assert.equal(await this.contract.ownerOf(1), accounts[0])
        })
    })

    describe('avoid duplicity', () => { 
        it('can\'t create the same star twice', async function () { 
            // new star
            await this.contract.createStar('awesome star!', 'dec1', 'mag1', 'cent1', 'story1', 1, {from: accounts[0]})
            // try to save the same
            await expectThrow(this.contract.createStar('awesome star!', 'dec1', 'mag1', 'cent1', 'story1', 2, {from: accounts[0]}))
        })
    })

    describe('Verify if star exists', () => {
        it('Star1 exists', async function(){
            // new star
            await this.contract.createStar('awesome star!', 'dec1', 'mag1', 'cent1', 'story1', 1, {from: accounts[0]})
            assert.equal(await this.contract.checkIfStarExist('dec1','mag1','cent1'), true)
        })
    })

    describe('buying and selling stars', () => { 
        let user1 = accounts[1]
        let user2 = accounts[2]
        let randomMaliciousUser = accounts[3]
        
        let starId = 99
        let starPrice = web3.toWei(.01, "ether")

        beforeEach(async function () { 
            await this.contract.createStar('awesome star!', 'dec1', 'mag1', 'cent1', 'story1', starId, {from: user1})    
        })

        it('user1 can put up their star for sale', async function () { 
            assert.equal(await this.contract.ownerOf(starId), user1)
            await this.contract.putStarUpForSale(starId, starPrice, {from: user1})
            
            assert.equal(await this.contract.starsForSale(starId), starPrice)
        })

        describe('user2 can buy a star that was put up for sale', () => { 
            beforeEach(async function () { 
                await this.contract.putStarUpForSale(starId, starPrice, {from: user1})
            })

            it('user2 is the owner of the star after they buy it', async function() { 
                await this.contract.buyStar(starId, {from: user2, value: starPrice, gasPrice: 0})
                assert.equal(await this.contract.ownerOf(starId), user2)
            })

            it('user2 ether balance changed correctly', async function () { 
                let overpaidAmount = web3.toWei(.05, 'ether')
                const balanceBeforeTransaction = web3.eth.getBalance(user2)
                await this.contract.buyStar(starId, {from: user2, value: overpaidAmount, gasPrice: 0})
                const balanceAfterTransaction = web3.eth.getBalance(user2)

                assert.equal(balanceBeforeTransaction.sub(balanceAfterTransaction), starPrice)
            })
        })
    })

    describe('aproving others', () => { 
        let user1 = accounts[1]
        let user2 = accounts[2]
        let randomMaliciousUser = accounts[3]
        let starId = 99

        beforeEach(async function () { 
            await this.contract.createStar('awesome star!', 'dec1', 'mag1', 'cent1', 'story1', starId, {from: user1})    
        })

        it('user 1 can approve user 2 for the star 1', async function (){
            await this.contract.approve(user2, starId, {from: user1})
            assert.equal(await this.contract.getApproved(starId), user2)
        })

        it('malicious user cant approve user2 for user1 star', async function () { 
            await expectThrow(this.contract.approve(user2, starId, {from: randomMaliciousUser}))
        })        

        it('user1 cant approve user1 (it self)', async function () { 
            await expectThrow(this.contract.approve(user1, starId, {from: user1}))
        })        
    })
})

var expectThrow = async function(promise) { 
    try { 
        await promise
    } catch (error) {
        assert.exists(error)
        return
    }
    assert.fail('Expected an error but didnt see one!')
}