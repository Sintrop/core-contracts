pragma solidity >=0.7.0 <=0.9.0;
// SPDX-License-Identifier: GPL-3.0-or-later

import "@openzeppelin/contracts/access/Ownable.sol";
import "./PoolInterface.sol";

interface SatTokenInterface {
    function allowance(address owner, address delegate) external view returns(uint);
    function approveWith(address delegate, uint numTokens) external returns(uint);
    function transferFrom(address owner, address to, uint numTokens) external returns(bool);
}

/**
* @title DeveloperContract
* @dev DeveloperPool is a contract to reward developers
*/
contract DeveloperPool is Ownable, PoolInterface {
    struct Developer {
        address _address;
        uint level;
        uint8 currentEra;
        uint createdAt;
    }

    mapping(address => Developer) internal developers;

    SatTokenInterface internal satToken;

    uint public developersCount;

    uint public tokensDistribute;

    uint public deployed_at;

    uint public era = 3600;

    uint public maxEras = 18;

    uint public levelsSum;

    constructor(address satTokenAddress, uint _tokensDistribute) {
        satToken = SatTokenInterface(satTokenAddress);
        deployed_at = block.timestamp;
        tokensDistribute = _tokensDistribute;
    }
    
    // METHODS TO DEVELOPER MANAGER //

    function getDeveloper(address _developerAddress) public view returns (Developer memory) {
        return developers[_developerAddress];
    }

    function add(address _developerAddress) public onlyOwner {
        developers[_developerAddress] = Developer(_developerAddress, 0, 1, block.timestamp);
        developersCount++;
    }

    function newLevel(address _developerAddress, uint8 _level) public onlyOwner {
        developers[_developerAddress].level += _level;
        levelsSum += _level;
    }

    // METHODS TO TOKEN POOL //

    function approve() public override returns(bool){
        Developer memory developer = getDeveloper(msg.sender);

        if (!canWithDraw(developer)) return false;

        satToken.approveWith(msg.sender, calcTokens(developer.level));

        developerNextEra();

        return true;
    }

    function canWithDraw(Developer memory developer) internal view returns(bool) {
        return canWithDrawFromPresent(block.timestamp, developer.currentEra);
    }

    function canWithDrawFromPresent(uint _currentTime, uint _currentEra) internal view returns(bool) {
        return deployed_at + (era * _currentEra) <= _currentTime;
    }

    function developerNextEra() internal { 
        developers[msg.sender].currentEra++;
    }

    function calcTokens(uint level) internal view returns(uint) {
        return level * (tokensDistribute / levelsSum);
    }

    function withDraw() public override returns(bool){
        satToken.transferFrom(address(this), msg.sender, allowance()); 
        return true;
    }

    function allowance() public override view returns (uint){
        return satToken.allowance(address(this), msg.sender);
    }
}