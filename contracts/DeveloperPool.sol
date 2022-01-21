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
        uint currentEra;
        uint createdAt;
    }

    struct Era {
        uint era;
        uint tokens;
        uint developers;
    }

    mapping(address => Developer) internal developers;
    mapping(uint => Era) public eras;

    SatTokenInterface internal satToken;

    uint public developersCount;

    uint public levelsSum;

    uint public deployedAt;

    uint public tokensPerEra;

    uint public blocksPerEra;

    uint public eraMax;

    constructor(address _satTokenAddress, uint _tokensPerEra, uint _blocksPerEra, uint _eraMax) {
        satToken = SatTokenInterface(_satTokenAddress);
        deployedAt = currentBlockNumber();
        tokensPerEra = _tokensPerEra;
        blocksPerEra = _blocksPerEra;
        eraMax = _eraMax;
    }
    
    // METHODS TO DEVELOPER MANAGER //

    function getDeveloper(address _address) public view returns (Developer memory) {
        return developers[_address];
    }

    function addDeveloper(address _address) public onlyOwner {
        uint currentEra = currentEraToNewDev();

        developers[_address] = Developer(_address, 1, currentEra, timestamp());
        levelsSum++;
        developersCount++;
    }

    function currentEraToNewDev() internal view returns(uint) {
        return (currentBlockNumber() - deployedAt) / blocksPerEra + 1;
    }

    function addLevel(address _address) public onlyOwner {
        developers[_address].level++;
        levelsSum++;
    }

    function undoLevel(address _address) public onlyOwner {
        Developer memory developer = getDeveloper(msg.sender);

        developers[_address].level = 0;

        levelsSum -= developer.level;
    }

    // METHODS TO TOKEN POOL //

    function approve() public override returns(bool){
        require(canWithDraw(), "You can't withdraw yet");

        Developer memory developer = getDeveloper(msg.sender);

        uint tokens = calcTokens(developer.level);

        satToken.approveWith(msg.sender, tokens);

        setEraMetrics(developer.currentEra, tokens);

        developerNextEra();

        if (canWithDraw()) approve();

        return true;
    }

    function setEraMetrics(uint _era, uint _tokens) internal {
        Era memory newEra = Era(_era, _tokens + eras[_era].tokens, 1 + eras[_era].developers);

        eras[_era] = newEra;
    }

    function withDraw() public override returns(bool){
        satToken.transferFrom(address(this), msg.sender, allowance()); 
        return true;
    }

    function allowance() public override view returns (uint){
        return satToken.allowance(address(this), msg.sender);
    }

    function canWithDraw() internal view returns(bool) {
        Developer memory developer = getDeveloper(msg.sender);

        if (developer.level == 0) return false;

        return canWithDrawFromPresent(currentBlockNumber(), developer.currentEra) && eraLimit(developer.currentEra);
    }

    function eraLimit(uint _currentEra) internal view returns(bool) {
        return _currentEra <= eraMax;
    }

    function canWithDrawFromPresent(uint _currentBlock, uint _currentEra) internal view returns(bool) {
        return deployedAt + (blocksPerEra * _currentEra) <= _currentBlock;
    }

    function developerNextEra() internal { 
        developers[msg.sender].currentEra++;
    }

    function calcTokens(uint _level) internal view returns(uint) {
        if (levelsSum == 0) return 0;
        return _level * (tokensPerEra / uint(levelsSum));
    }

    function nextWithdrawalTime() public view returns(int) {
        Developer memory developer = getDeveloper(msg.sender);

        return int(deployedAt) + (int(blocksPerEra) * int(developer.currentEra)) - int(currentBlockNumber());
    }

    function timestamp() internal view returns(uint) {
        return block.timestamp;
    }

    function currentBlockNumber() internal view returns(uint) {
        return block.number;
    }

}
