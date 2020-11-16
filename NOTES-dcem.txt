 // on solidity
//struct
struct Token {

address tokenContract;

string symbolName;
}

//we support a max of 255 tokens...
mapping (uint8 => Token) tokens;

uint8 symbolNameIndex;

//events for token management
event TokenAddedToSystem(uint _symbolIndex, string _token, uint _timestamp);


//////////////////////
// TOKEN MANAGEMENT //
//////////////////////

function addToken(string symbolName, address erc20TokenAddress) onlyowner {
    require(!hasToken(symbolName));
    require(symbolNameIndex + 1 > symbolNameIndex);
    symbolNameIndex++;

    tokens[symbolNameIndex].symbolName = symbolName;
    tokens[symbolNameIndex].tokenContract = erc20TokenAddress;
    TokenAddedToSystem(symbolNameIndex, symbolName, now);
}

function hasToken(string symbolName) constant returns (bool) {
    uint8 index = getSymbolIndex(symbolName);
    if (index == 0) {
        return false;
    }
    return true;
}


function getSymbolIndex(string symbolName) internal returns (uint8) {
    for (uint8 i = 1; i <= symbolNameIndex; i++) {
        if (stringsEqual(tokens[i].symbolName, symbolName)) {
            return i;
        }
    }
    return 0;
}


function getSymbolIndexOrThrow(string symbolName) returns (uint8) {
    uint8 index = getSymbolIndex(symbolName);
    require(index > 0);
    return index;
}


//////////////////////
// TOKEN MANAGEMENT - ammended //
//////////////////////

function addToken(string symbolName, address erc20TokenAddress) onlyowner {
    require(!hasToken(symbolName));
    require(symbolNameIndex + 1 > symbolNameIndex);
    symbolNameIndex++;

    tokenslist[symbolNameIndex].symbolName = symbolName;
    tokenslist[symbolNameIndex].tokenContract = erc20TokenAddress;
    TokenAddedToSystem(symbolNameIndex, symbolName, now);
}

function hasToken(string symbolName) constant returns (bool) {
    uint8 index = getSymbolIndex(symbolName);
    if (index == 0) {
        return false;
    }
    return true;
}


function getSymbolIndex(string symbolName) internal returns (uint8) {
    for (uint8 i = 1; i <= symbolNameIndex; i++) {
        if (stringsEqual(tokenslist[i].symbolName, symbolName)) {
            return i;
        }
    }
    return 0;
}


function getSymbolIndexOrThrow(string symbolName) returns (uint8) {
    uint8 index = getSymbolIndex(symbolName);
    require(index > 0);
    return index;
}


*/

//on app.js
addTokenToExchange: function () {
    //function to add tokens to the exchange

    var nameOfToken = document.getElementById("inputNameTokenAddExchange").value;
    var addressOfToken = document.getElementById("inputAddressTokenAddExchange").value;
    ExchangeContract.deployed().then(function (instance) {
        return instance.addToken(nameOfToken, addressOfToken, {from: account});
    }).then(function (txResult) {
        console.log(txResult);
        App.setStatus("Token added");
    }).catch(function (e) {
        console.log(e);
        App.setStatus("Error getting balance; see log.");
    });
},

//on managetoken.html

<div class="panel panel-default">
    <div class="panel-heading">Add Token to Exchange</div>
    <div class="panel-body">
        <form>
            <div class="form-group">
                <label for="inputNameTokenAddExchange">Name of the Token</label>
                <input type="text" name="inputNameTokenAddExchange" class="form-control"
                       id="inputNameTokenAddExchange" placeholder="FIXED">
            </div>
            <div class="form-group">
                <label for="inputAddressTokenAddExchange">Address of Token</label>
                <input type="text" class="form-control" id="inputAddressTokenAddExchange"
                       name="inputAddressTokenAddExchange" placeholder="e.g. 0x123ABde44...">
            </div>
            <button type="button" class="btn btn-default" onclick="App.addTokenToExchange();return false;">
                Add Token to Exchange
            </button>
        </form>

    </div>
</div>
</div>
