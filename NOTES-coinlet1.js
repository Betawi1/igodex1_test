//in main.js line 17

const configName = getParameterByName('config');
let config;
if (configName === 'testnet') {
  config = require('./config_testnet.js'); // eslint-disable-line global-require
} else {
  config = require('./config.js'); // eslint-disable-line global-require
}


//in main.js line 1948
BitDex.prototype.getToken = function getToken(addrOrToken, name, decimals) {
  let result;
  const lowerAddrOrToken = typeof addrOrToken === 'string' ? addrOrToken.toLowerCase() : addrOrToken;
  const matchingTokens = this.config.tokens.filter(
    x => x.addr.toLowerCase() === lowerAddrOrToken ||
    x.name === addrOrToken);
  const expectedKeys = JSON.stringify([
    'addr',
    'decimals',
    'name',
  ]);
  if (matchingTokens.length > 0) {
    result = matchingTokens[0];
  } else if (this.selectedToken.addr.toLowerCase() === lowerAddrOrToken) {
    result = this.selectedToken;
  } else if (this.selectedBase.addr.toLowerCase() === lowerAddrOrToken) {
    result = this.selectedBase;
  } else if (addrOrToken && addrOrToken.addr &&
  JSON.stringify(Object.keys(addrOrToken).sort()) === expectedKeys) {
    result = addrOrToken;
  } else if (typeof addrOrToken === 'string' && addrOrToken.slice(0, 2) === '0x' && name && decimals >= 0) {
    result = JSON.parse(JSON.stringify(this.config.tokens[0]));
    result.addr = lowerAddrOrToken;``
    result.name = name;
    result.decimals = decimals;
  }
  return result;
};
BitDex.prototype.loadToken = function loadToken(addr, callback) {
  let token = this.getToken(addr);
  if (token) {
    callback(null, token);
  } else {
    token = JSON.parse(JSON.stringify(this.config.tokens[0]));
    if (addr.slice(0, 2) === '0x') {
      token.addr = addr.toLowerCase();
      utility.call(this.web3, this.contractToken, token.addr, 'decimals', [], (err, result) => {
        if (!err && result >= 0) token.decimals = result.toNumber();
        utility.call(this.web3, this.contractToken, token.addr, 'name', [], (errName, resultName) => {
          if (!errName && resultName) {
            token.name = resultName;
          } else {
            token.name = token.addr.slice(2, 6);
          }
          callback(null, token);
        });
      });
    } else {
      callback(null, token);
    }
  }
};
BitDex.prototype.selectToken = function selectToken(addrOrToken, name, decimals) {
  const token = this.getToken(addrOrToken, name, decimals);
  if (token) {
    this.loading(() => {});
    this.refresh(() => {}, true, true, token, this.selectedBase);
    ga('send', {
      hitType: 'event',
      eventCategory: 'Token',
      eventAction: 'Select Token',
      eventLabel: this.selectedToken.name,
    });
  }
};
BitDex.prototype.selectBase = function selectBase(addrOrToken, name, decimals) {
  const base = this.getToken(addrOrToken, name, decimals);
  if (base) {
    this.loading(() => {});
    this.refresh(() => {}, true, true, this.selectedToken, base);
    ga('send', {
      hitType: 'event',
      eventCategory: 'Token',
      eventAction: 'Select Base',
      eventLabel: this.selectedBase.name,
    });
  }
};
BitDex.prototype.selectTokenAndBase = function selectTokenAndBase(tokenAddr, baseAddr) {
  const token = this.getToken(tokenAddr);
  const base = this.getToken(baseAddr);
  if (token && base) {
    this.loading(() => {});
    this.refresh(() => {}, true, true, token, base);
    ga('send', {
      hitType: 'event',
      eventCategory: 'Token',
      eventAction: 'Select Pair',
      eventLabel: `${this.selectedToken.name}/${this.selectedBase.name}`,
    });
  }
};

// load contract line 2466
utility.loadContract(
  this.web3,
  this.config.contractBitDex,
  this.config.contractBitDexAddr,
  (err, contractBitDex) => {
    this.contractBitDex = contractBitDex;
    utility.loadContract(
      this.web3,
      this.config.contractToken,
      '0x0000000000000000000000000000000000000000',
      (errLoadContract, contractToken) => {
        this.contractToken = contractToken;
        // select token and base
        const hash = window.location.hash.substr(1);
        const hashSplit = hash.split('-');
        // get token and base from hash
        async.parallel(
          [
            (callbackParallel) => {
              if (hashSplit.length === 2) {
                this.loadToken(hashSplit[0], (errLoadToken, result) => {
                  if (!errLoadToken && result) this.selectedToken = result;
                  callbackParallel(null, true);
                });
              } else {
                callbackParallel(null, true);
              }
            },
            (callbackParallel) => {
              if (hashSplit.length === 2) {
                this.loadToken(hashSplit[1], (errLoadToken, result) => {
                  if (!errLoadToken && result) this.selectedBase = result;
                  callbackParallel(null, true);
                });
              } else {
                callbackParallel(null, true);
              }
            }],
          () => {
            callback();
          });
      });
  });
});
};

in trade.js

self.getContract = function getContract(callback) {
  self.get(`https://api.etherscan.io/api?module=contract&action=getabi&address=${addressBitDex}`, (err, data) => {
    if (err) throw new Error(err);
    const abi = JSON.parse(data.result);
    self.contractBitDex = web3.eth.contract(abi);
    self.contractBitDex = self.contractBitDex.at(addressBitDex);
    callback(null, self.contractBitDex);
  });
};

self.getContractToken = function getContractToken(callback) {
  self.get(`https://api.etherscan.io/api?module=contract&action=getabi&address=${addressToken}`, (err, data) => {
    if (err) throw new Error(err);
    const abi = JSON.parse(data.result);
    self.contractToken = web3.eth.contract(abi);
    self.contractToken = self.contractToken.at(addressToken);
    callback(null, self.contractToken);
  });
};

self.getBlockNumber = function getBlockNumber(callback) {
  self.get('https://api.etherscan.io/api?module=proxy&action=eth_blockNumber', (err, data) => {
    if (!err) {
      const newBlockNumber = web3.toDecimal(data.result);
      if (newBlockNumber > 0) {
        self.blockNumber = newBlockNumber;
      }
      callback(null, self.blockNumber);
    } else {
      callback(null, self.blockNumber);
    }
  });
};

self.getLog = function getLog(fromBlock, toBlock, callback) {
  function decodeEvent(item) {
    const eventAbis = self.contractBitDex.abi.filter(eventAbi => (
        eventAbi.type === 'event' &&
        item.topics[0] ===
          `0x${
            sha3(
              `${eventAbi.name
                }(${
                eventAbi.inputs
                  .map(x => x.type)
                  .join()
                })`)}`
      ));
    if (eventAbis.length > 0) {
      const eventAbi = eventAbis[0];
      const event = new SolidityEvent(web3, eventAbi, addressBitDex);
      const result = event.decode(item);
      return result;
    }
    return null;
  }
  const url =
    `https://api.etherscan.io/api?module=logs&action=getLogs&address=${addressBitDex}&fromBlock=${fromBlock}&toBlock=${toBlock}`;
  self.get(url, (err, data) => {
    if (!err) {
      try {
        const items = data.result;
        async.map(
          items,
          (item, callbackMap) => {
            Object.assign(item, {
              blockNumber: parseInt(item.blockNumber, 16),
              logIndex: parseInt(item.logIndex, 16),
              transactionIndex: parseInt(item.transactionIndex, 16),
            });
            const event = decodeEvent(item);
            callbackMap(null, event);
          },
          (errMap, events) => {
            callback(null, events);
          });
      } catch (errTry) {
        callback(errTry, []);
      }
    } else {
      callback(err, []);
    }
  });
};

self.getCall = function getCall(contract, addr, fn, args, callback) {
  const data = contract[fn].getData.apply(null, args);
  const url = `https://api.etherscan.io/api?module=proxy&action=eth_call&to=${addr}&data=${data}&tag=latest`;
  self.get(url, callback);
};

self.getTokenInfo = function getTokenInfo(addr, callback) {
  if (self.tokens[addr]) {
    callback(null, self.tokens[addr]);
  } else {
    self.getCall(self.contractToken, addr, 'symbol', [], (errSymbol, dataSymbol) => {
      self.getCall(self.contractToken, addr, 'decimals', [], (errDecimals, dataDecimals) => {
        if (!errSymbol && !errDecimals) {
          try {
            const symbol = web3.toAscii(dataSymbol.result).replace(/[\u{0000}-\u{0020}]/gu, '');
            const decimals = web3.toDecimal(dataDecimals.result);
            self.tokens[addr] = {
              addr,
              decimals,
              name: symbol,
            };
          } catch (err) {
            console.log('Error getting token', addr);
          }
          callback(null, self.tokens[addr]);
        } else {
          callback('Failed to get token', null);
        }
      });
    });
  }
};
