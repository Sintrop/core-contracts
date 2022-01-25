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
    using SafeMath for uint256;

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
        return currentBlockNumber().sub(deployedAt).div(blocksPerEra).add(1);
    }

    function addLevel(address _address) public onlyOwner {
        developers[_address].level++;
        levelsSum++;
    }

    function undoLevel(address _address) public onlyOwner {
        Developer memory developer = getDeveloper(_address);
        levelsSum -= developer.level;
        developers[_address].level = 0;
    }

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
        uint oneDev = 1;
        Era memory newEra = Era(_era, _tokens.add(eras[_era].tokens), oneDev.add(eras[_era].developers));
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
        return deployedAt.add(blocksPerEra.mul(_currentEra)) <= _currentBlock;
    }

    function developerNextEra() internal { 
        developers[msg.sender].currentEra++;
    }

    function calcTokens(uint _level) internal view returns(uint) {
        uint _levelsSum = uint(levelsSum);
        if (_levelsSum == 0) return 0;
        return _level.mul((tokensPerEra.div(_levelsSum)));
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
