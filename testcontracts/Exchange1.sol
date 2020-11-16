pragma solidity ^0.5.0;

import "./Token.sol";  //can be used by any other ERC20 tokens. so not necessary to import other tokens here.
import "openzeppelin-solidity/contracts/math/SafeMath.sol";  // this is to use mathematical function like: .sub and .add

contract Exchange {
    using SafeMath for uint;  // tell the smart contract that we r using SafeMath.sol
//state variables
    address public feeAccount;  // the account that receives the exchange fees
    uint256 public feePercent;  //the fee percentage
    address constant ETHER = address(0); //to store Ether in tokens mapping with blank address, can this work with real Ether ?? tbc
    mapping(address => mapping(address => uint256)) public tokens; //1st address is the token addresses, 2nd address are the user who has deposited the tokens & their balances (uint256).
    mapping(uint256 => _Order) public orders;  //stored the struct (_Order) in orders mapping (2.a way to store the order).
    uint256 public orderCount;  //countercash to keep track of the orders.it will start at 0.
    mapping(uint256 => bool) public orderCancelled;  //mapping to store cancelled orders.
    mapping(uint256 => bool) public orderFilled; //mapping to store filled orders.

//test dcem add token
    mapping (uint8 => TokenList) public tokenslist;
    uint8 public symbolNameIndex;


//test dcem events for token management
    event TokenAddedToSystem(
      uint _symbolIndex,
      string _tokenlist,
      uint _timestamp
      );

// Events
    event Deposit(address token, address user, uint256 amount, uint256 balance); //define the event
    event Withdraw(address token, address user, uint256 amount, uint256 balance);
    event Order(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
        );
    event Cancel(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
        );

    event Trade(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        address userFill,
        uint256 timestamp
        );


//structs : (1. a way to model the orders) solidity allows us to do our custom/own data type (_Order), which we can add all the attributes of the order.
    struct _Order {
        uint256 id;
        address user;   //the user1 who created the order
        address tokenGet;  //address of the token the user1 wants to buy/purchase
        uint256 amountGet;
        address tokenGive;  //token that user1 wants to sell/give
        uint256 amountGive;
        uint256 timestamp;
    }

//test dcem structs
    struct TokenList {
      address tokenContract;
      string symbolName;
    }


    constructor (address _feeAccount, uint256 _feePercent) public {
        feeAccount = _feeAccount;
        feePercent = _feePercent;
    }

//Fallback: reverts if Ether is sent to this smart contrac by mistake.
    function() external {
        revert();
    }

    function depositEther() payable public {
      //for a function to accept ETH must use 'payable' and its refer as msg.value
        tokens[ETHER][msg.sender] = tokens[ETHER][msg.sender].add(msg.value);    //Manage deposit - update balance (internal tracking mechanism to track the amount, owner of ETH)
        emit Deposit(ETHER, msg.sender, msg.value, tokens[ETHER][msg.sender]);  //Emit an event
    }

    function withdrawEther(uint _amount) public {
        require(tokens[ETHER][msg.sender] >= _amount);  // ensure that there is enough ETH to be withdrawn.
        tokens[ETHER][msg.sender] = tokens[ETHER][msg.sender].sub(_amount);    //Manage withdrawal - update balance (internal tracking mechanism to track the amount, owner of ETH)
        msg.sender.transfer(_amount);
        emit Withdraw(ETHER, msg.sender, _amount, tokens[ETHER][msg.sender]);  //Emit an event
    }

    function depositToken(address _token, uint _amount) public {
      //which token ? because this can be any ERC20 tokens: use 'address _token'.
      //How much ?: use 'uint _amount'.
      //TODO: Don't allow Ether deposit
        require(_token != address(0)); //address (0) is ETH as declared in the variables.
        require(Token(_token).transferFrom(msg.sender, address(this), _amount));  //to ensure that the transferFrom (//send token to this contract) is/has executed, use 'require'. Token(_token) is instance of the token contract.
        tokens[_token][msg.sender] = tokens[_token][msg.sender].add(_amount);    //Manage deposit - update balance (internal tracking mechanism to track the amount, owner of tokens)
        emit Deposit(_token, msg.sender, _amount, tokens[_token][msg.sender]);  //Emit an event
    }

    function withdrawToken(address _token, uint256 _amount) public {
        require(_token != ETHER); //its not ETH to withdraw
        require(tokens[_token][msg.sender] >= _amount);  // ensure that there is enough token  to be withdrawn.
        tokens[_token][msg.sender] = tokens[_token][msg.sender].sub(_amount);    //Manage withdrawal - update balance (internal tracking mechanism to track the amount, owner of ETH)
        require(Token(_token).transfer(msg.sender, _amount));   //transfer the token from smart contract to the user1.
        emit Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender]);  //Emit an event
    }

    function balanceOf(address _token, address _user) public view returns (uint256) {
        return tokens[_token][_user];   // just to check the balance of the tokens and the user whick onwed it.
    }
//3. add the order to storage
    function makeOrder(address _tokenGet, uint256 _amountGet, address _tokenGive, uint256 _amountGive) public {
        orderCount = orderCount.add(1);    //use counter cash to create id.
        orders[orderCount] = _Order(orderCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, now);  //instantiate(initialize) the order, add orders to the 'orders' mapping. 'now' is the timestamp.
        emit Order(orderCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, now);
    }

    function cancelOrder(uint256 _id) public {
        _Order storage _order = orders[_id];  //fetching the order from the mapping (storage) using the orders id, and state it as new internal variable called  _order
        require(address(_order.user) == msg.sender);  //must be my order.
        require(_order.id == _id); //order must exist
        orderCancelled[_id] = true; //add to a 'canceledOrder mapping', since cannot take out from orders mapping (blockchain can't delete)
        emit Cancel(_order.id, msg.sender, _order.tokenGet, _order.amountGet, _order.tokenGive, _order.amountGive, now);
    }

    function fillOrder(uint256 _id) public {
      require(_id > 0 && _id <= orderCount);   //check if the order id is valid.
      require(!orderFilled[_id]);  //b4 filling order, check if its already filled or not.
      require(!orderCancelled[_id]);  //b4 filling order, check if its already cancelled ot not.
      _Order storage _order = orders[_id];  //fetch the order from storage
      _trade(_order.id, _order.user, _order.tokenGet, _order.amountGet, _order.tokenGive, _order.amountGive);
      orderFilled[_order.id] = true;  //mark the order as filled
    }


    function _trade(uint256 _orderId, address _user, address _tokenGet, uint256 _amountGet, address _tokenGive, uint256 _amountGive) internal {
            // Fee paid by the user that fills the order, a.k.a. msg.sender.fee deducted from _amountGet (buy order amount)
            uint256 _feeAmount = _amountGet.mul(feePercent).div(100);

            //execute trade by swapping btw msg.sender(filler), user(creator) & charge fees
            tokens[_tokenGet][msg.sender] = tokens[_tokenGet][msg.sender].sub(_amountGet.add(_feeAmount));
            tokens[_tokenGet][_user] = tokens[_tokenGet][_user].add(_amountGet);
            tokens[_tokenGet][feeAccount] = tokens[_tokenGet][feeAccount].add(_feeAmount);
            tokens[_tokenGive][_user] = tokens[_tokenGive][_user].sub(_amountGive);

            tokens[_tokenGive][msg.sender] = tokens[_tokenGive][msg.sender].add(_amountGive);
            //Emit trade event
            emit Trade(_orderId, _user, _tokenGet, _amountGet, _tokenGive, _amountGive, msg.sender, now);
        }

        /////////////////////
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



}
