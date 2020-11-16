pragma solidity ^0.5.0; //declare the solidity version to truffle

import "openzeppelin-solidity/contracts/math/SafeMath.sol";  // this is to use mathematical function like: .sub and .add

contract Token {
    using SafeMath for uint;  // tell the smart contract that we r using SafeMath.sol

//Variables
    string public name = "IGO Token";  //put string first, since need to declare the type of var first, b4 defining the var & public so that we can call the name of the smart contract.
    string public symbol = "IGO"; //these are all state var
    uint256 public decimals = 18; //uint means the number cannot be negative
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;  //track balances (storing data on the blockchain) //balanceOf is the mapping name
    mapping(address => mapping(address => uint256)) public allowance;  //allowance mapping to see how many tokens can the exchange spend on our behalf, 1st address is the person who approves, 2nd address are all the exchanges addresses approved.


// Events, here is to define the events in the smart contract
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //constructor function runs only one time during the first deployment.
    constructor() public {
          totalSupply = 1000000 * (10 ** decimals);
          balanceOf[msg.sender] = totalSupply; //this is to assign all the tokens to the deployer.'function balanceOf(address _owner) public view returns (uint256 balance)''
    }
      //send tokensfunction transfer(address _to, uint256 _value) public returns (bool success)
    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);  //The function SHOULD throw if the message caller's account balance does not have enough tokens to spend.
        _transfer(msg.sender, _to, _value);  //call the internal _transfer function.
        return true;
    }

    // refactor transfer function into an internal function _transfer, so it can be reusable.
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0));  // the function should throw if invalid recipient
        balanceOf[_from] = balanceOf[_from].sub(_value);    //implement the logic: step 1 decrease current owner, (whoever who calls this function i.e.msg.sender) balance
        balanceOf[_to] = balanceOf[_to].add(_value);    //step 2 increase the balance of receiver
        emit Transfer(_from, _to, _value);  // under the EIPS-20 Transfer event, MUST fire the Transfer event
    }


//approve tokens to allocate to exchange
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));  // the function should throw if invalid recipient
      //create the logic
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);  // under the EIPS-20 TransferFrom event, MUST fire the approve event
        return true;
    }

//transfer from function:
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //guard against insufficient amount
        require(_value <= balanceOf[_from]);    //spender must have enough token to complete the transfer
        require(_value <= allowance[_from][msg.sender]);  //the value must be less than the approved amount
        //logic
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true; // require by the command 'bool success'
    }
}
