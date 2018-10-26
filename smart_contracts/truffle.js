var HDWalletProvider = require('truffle-hdwallet-provider');

var mnemonic = 'city lunch ecology unusual monkey blast online excuse admit mask gorilla room';

module.exports = {
  networks: { 
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: "*"
    }, 
    rinkeby: {
      provider: function() { 
        return new HDWalletProvider(mnemonic, 'https://rinkeby.infura.io/v3/41cec3890cb44096a0abae60848af248')
      },
      network_id: 4,
      gas: 4500000,
      gasPrice: 10000000000,
    }
  }
};