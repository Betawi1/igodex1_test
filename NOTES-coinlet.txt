//GET TOKEN ABI from Etherscan

// https://api.etherscan.io/api?module=contract&action=getabi&address=0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413&apikey=YourApiKeyToken


  self.getContractToken = function getContractToken(callback) {
    self.get(`https://api.etherscan.io/api?module=contract&action=getabi&address=${addressToken}`, (err, data) => {
      if (err) throw new Error(err);
      const abi = JSON.parse(data.result);
      self.contractToken = web3.eth.contract(abi);
      self.contractToken = self.contractToken.at(addressToken);
      callback(null, self.contractToken);
    });
  };


//this is in the api.js which links to coinlet-config.js file

  API.getTokenByAddr = function getTokenByAddr(addr, callback) {
    let token;
    const matchingTokens = this.config.tokens.filter(x => x.addr === addr || x.name === addr);
    if (matchingTokens.length > 0) {
      token = matchingTokens[0];
      callback(token);
    } else if (addr.slice(0, 2) === '0x') {
      token = JSON.parse(JSON.stringify(this.config.tokens[0]));
      token.addr = addr;
      this.utility.call(this.web3, this.contractToken, token.addr, 'decimals', [], (errDecimals, resultDecimals) => {
        if (!errDecimals && resultDecimals >= 0) token.decimals = resultDecimals.toNumber();
        this.utility.call(this.web3, this.contractToken, token.addr, 'name', [], (errName, resultName) => {
          if (!errName && resultName) {
            token.name = resultName;
          } else {
            token.name = token.addr.slice(2, 6);
          }
          this.config.tokens.push(token);
          callback(token);
        });
      });
    } else {
      callback(token);
    }
  };

  API.getToken = function getToken(addrOrToken, name, decimals) {
    let result;
    const matchingTokens = this.config.tokens.filter(
      x => x.addr === addrOrToken ||
      x.name === addrOrToken);
    const expectedKeys = JSON.stringify([
      'addr',
      'decimals',
      'name',
    ]);
    if (matchingTokens.length > 0) {
      result = matchingTokens[0];
    } else if (addrOrToken.addr && JSON.stringify(Object.keys(addrOrToken).sort()) === expectedKeys) {
      result = addrOrToken;
    } else if (addrOrToken.slice(0, 2) === '0x' && name && decimals >= 0) {
      result = JSON.parse(JSON.stringify(this.config.tokens[0]));
      result.addr = addrOrToken;
      result.name = name;
      result.decimals = decimals;
    }
    return result;
  };

  // Made in dreams :

  import "./Token.sol"; <---------- my token

Token token = new Token();     <----- new token instance


So if you do

Token(TransferFrom (,,,, ..., ...))  You are working with your token contract only

so I made a new function

function getERCtransfer(address _token, address _to, uint256 _value) public returns (bool){
         token = Token(_token);
       return token.transfer(_to, _value);

I specify the contract address of the token i want to transfer and i can transfer any token now
