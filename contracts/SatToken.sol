// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

import "./Ownable.sol";

import "./SafeMath.sol";

contract SatToken is Ownable {
    string public constant NAME = "SUSTAINABLE AGRICULTURE TOKEN";
    string public constant SYMBOL = "SAT";
    uint8 public constant DECIMALS = 18;  

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);

    mapping(address => uint256) internal balances;
    mapping(address => mapping (address => uint256)) internal allowed;

    uint256 internal totalSupply_;

    using SafeMath for uint256;

    mapping( address => bool) internal contractsPools;

    constructor(uint256 total) {  
        totalSupply_ = total;
        balances[msg.sender] = totalSupply_;
    }

    // =====================================================
    function addContractPool(address _fundAddress, uint _numTokens) public onlyOwner returns(bool) {
        contractsPools[_fundAddress] = true;
        transfer(_fundAddress, _numTokens);
        return true;
    }

    function approveWith(address delegate, uint numTokens) public returns(uint) {
        require(contractPool(msg.sender), "Not a contract pool");

        allowed[msg.sender][delegate] = numTokens + allowance(msg.sender, delegate);
        emit Approval(msg.sender, delegate, numTokens);
        return numTokens;
    }

    function contractPool(address contractFundsAddress) internal view returns(bool){
        return contractsPools[contractFundsAddress];
    }
    // ==================================

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
