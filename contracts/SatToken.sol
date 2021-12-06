pragma solidity >=0.5.0 <=0.9.0;
// SPDX-License-Identifier: GPL-3.0-or-later

interface SintropInterface {
    function getProducerApprove(address delegate) external view returns(uint);
}

contract SatTokenERC20 {
    string public constant name = "SUSTAINABLE AGRICULTURE TOKEN";
    string public constant symbol = "SAT";
    uint8 public constant decimals = 18;  

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_;
    address producerFundsAddress_;
    address activistFundsAddress_;

    using SafeMath for uint256;
    SintropInterface sintrop;

    constructor(uint256 total, address _producerFundsAddress, address _activistFundsAddress) {  
        totalSupply_ = total;
        producerFundsAddress_ = _producerFundsAddress;
        activistFundsAddress_ = _activistFundsAddress;
        shareFunds(_producerFundsAddress, _activistFundsAddress);
    }  

    function setSintropAddress(address sintropAddress) public {
        sintrop = SintropInterface(sintropAddress);
    }

    function producerFundsAddress() public view returns(address) {
        return producerFundsAddress_;
    }

    function activistFundsAddress() public view returns(address) {
        return activistFundsAddress_;
    }

    function shareFunds(address _producerFundsAddress, address _activistFundsAddress) internal {
        uint ownerFunds = totalSupply_/2;
        balances[msg.sender] = ownerFunds;
        balances[_producerFundsAddress] = (totalSupply_ - ownerFunds)/2;
        balances[_activistFundsAddress] = (totalSupply_ - ownerFunds)/2;
    }

    function approveWith(address from, address delegate) public returns(uint) {
        if (from != producerFundsAddress_ && from != activistFundsAddress_) return 0;

        uint numTokens = sintrop.getProducerApprove(delegate);
        allowed[from][delegate] = numTokens;
        emit Approval(from, delegate, numTokens);
        return numTokens;
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
        require(numTokens <= balances[owner]);    
        require(numTokens <= allowed[owner][msg.sender]);
    
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}

library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}