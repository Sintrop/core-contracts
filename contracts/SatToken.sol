// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./SafeMath.sol";

contract SatToken is Ownable {
    string public constant NAME = "SUSTAINABLE AGRICULTURE TOKEN";
    string public constant SYMBOL = "SAT";
    uint8 public constant DECIMALS = 18;

    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
    event Transfer(address indexed from, address indexed to, uint256 tokens);

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    uint256 internal totalSupply_;

    using SafeMath for uint256;

    mapping(address => bool) internal contractsPools;

    constructor(uint256 total) {
        totalSupply_ = total;
        balances[msg.sender] = totalSupply_;
    }

    function addContractPool(address _fundAddress, uint256 _numTokens)
        public
        onlyOwner
        returns (bool)
    {
        contractsPools[_fundAddress] = true;
        transfer(_fundAddress, _numTokens);
        return true;
    }

    function removeContractPool(address _fundAddress)
        public
        onlyOwner
        returns (bool)
    {
        contractsPools[_fundAddress] = false;
        return true;
    }

    function approveWith(address delegate, uint256 numTokens)
        public
        mustBeContractPool
        returns (uint256)
    {
        allowed[msg.sender][delegate] =
            numTokens +
            allowance(msg.sender, delegate);
        emit Approval(msg.sender, delegate, numTokens);
        return numTokens;
    }

    function transferWith(address tokenOwner, uint256 numTokens)
        public
        mustBeContractPool
        mustHaveSacTokens(tokenOwner, numTokens)
        returns (bool)
    {
        balances[tokenOwner] = balances[tokenOwner].sub(numTokens);
        balances[msg.sender] = balances[msg.sender].add(numTokens);
        emit Transfer(tokenOwner, msg.sender, numTokens);

        return true;
    }

    function contractPool(address contractFundsAddress)
        internal
        view
        returns (bool)
    {
        return contractsPools[contractFundsAddress];
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens)
        public
        returns (bool)
    {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens)
        public
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function transferFrom(
        address owner,
        address buyer,
        uint256 numTokens
    ) public returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    modifier mustBeContractPool() {
        require(contractPool(msg.sender), "Not a contract pool");
        _;
    }

    modifier mustHaveSacTokens(address tokenOwner, uint256 numTokens) {
        require(numTokens <= balances[tokenOwner], "You don't has SAC Tokens");
        _;
    }
}
