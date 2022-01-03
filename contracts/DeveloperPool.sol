pragma solidity >=0.7.0 <=0.9.0;
// SPDX-License-Identifier: GPL-3.0-or-later

// import "@openzeppelin/contracts/access/Ownable.sol";
import "./PoolInterface.sol";

interface SatTokenInterface {
    function allowance(address owner, address delegate) external view returns(uint);
    function approveWith(address delegate, uint numTokens) external returns(uint);
    function transferFrom(address owner, address to, uint numTokens) external returns(bool);
}

contract Ownable {

  modifier onlyOwner {
    _;
  }
}

/**
* @title DeveloperContract
* @dev DeveloperPool is a contract to reward developers
*/
contract DeveloperPool is Ownable, PoolInterface {
    struct Developer {
        address _address;
        uint8 level;
        uint8 contributions;
        uint tokens;
    }
    uint public developersCount;

    mapping(address => Developer) developers;

    SatTokenInterface satToken;

    constructor(address satTokenAddress) {
        satToken = SatTokenInterface(satTokenAddress);
    }
    
    // METHODS TO DEVELOPER MANAGE

    function getDeveloper(address _developerAddress) public view returns (Developer memory) {
        return developers[_developerAddress];
    }

    function add(address _developerAddress) public onlyOwner {
        Developer memory developer = Developer(_developerAddress, 1, 0, 0);
        developers[_developerAddress] = developer;
        developersCount++;
    }

    function newContribuitions(address _developerAddress, uint8 _contributions) public onlyOwner {
        developers[_developerAddress].contributions += _contributions;
    }

    function newLevel(address _developerAddress, uint8 _level) public onlyOwner {
        developers[_developerAddress].level += _level;
    }

    function newTokens(address _developerAddress, uint8 _tokens) public onlyOwner {
        developers[_developerAddress].tokens += _tokens;
    }

    // METHODS TO TOKEN POOL BELOW

    function undoDeveloperTokens() internal {
        developers[msg.sender].tokens = 0;
    }

    function approve() public override returns(bool){
        satToken.approveWith(msg.sender, developers[msg.sender].tokens);

        undoDeveloperTokens();

        return true;
    }

    function withDraw() public override returns(bool){
        satToken.transferFrom(address(this), msg.sender, allowance()); 
        return true;
    }

    function allowance() public override view returns (uint){
        return satToken.allowance(address(this), msg.sender);
    }
}