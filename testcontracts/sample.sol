struct Item {
  uint price;
  uint units;
}
Item[] public items;

      function getUsingStorage(uint _itemIdx)
public

returns (uint)
{
  Item storage item = items[_itemIdx];
  return item.units;
}

 function addItemUsingStorage(uint _itemIdx, uint _units)
public
{
  Item storage item = items[_itemIdx];
  item.units += _units;
}


struct Tokenlist {
  address tokenContract;
  string symbolName;
}

mapping (uint8 => TokenList) tokenslist;
uint8 symbolNameIndex;
uint8 public tokenCount; ??

event TokenAddedToSystem(
  uint _symbolIndex,
  string _token,
  uint _timestamp);
//string _token

function addToken(string symbolName, address erc20TokenAddress) onlyowner {
    require(!hasToken(symbolName));
    require(symbolNameIndex + 1 > symbolNameIndex);
    symbolNameIndex++;

    tokenslist;
