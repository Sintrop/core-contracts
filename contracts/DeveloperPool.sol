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

    /**
   * @dev Return a specific developer
   * @param _address the address of the developer
   */
    function getDeveloper(address _address) public view returns (Developer memory) {
        return developers[_address];
    }

    /**
   * @dev Add a new develop to the pool
   * @param _address the address of the developer
   */
    function addDeveloper(address _address) public onlyOwner {
        uint currentEra = currentEraToNewDev();

        developers[_address] = Developer(_address, 1, currentEra, timestamp());
        levelsSum++;
        developersCount++;
    }

    /**
   * @dev Set the current era of the develop. The current era of the develop is the current era of the pool
   */
    function currentEraToNewDev() internal view returns(uint) {
        return currentBlockNumber().sub(deployedAt).div(blocksPerEra).add(1);
    }

    /**
   * @dev Increment the level of the develop
   * @param _address the address of the developer
   */
    function addLevel(address _address) public onlyOwner {
        developers[_address].level++;
        levelsSum++;
    }

    /**
   * @dev Set to zero the level of the develop
   * @param _address the address of the developer
   */
    function undoLevel(address _address) public onlyOwner {
        Developer memory developer = getDeveloper(_address);
        levelsSum -= developer.level;
        developers[_address].level = 0;
    }

    /**
   * @dev Allow the developer to approve tokens from DeveloperPool address. DeveloperPool address must have tokens in SAT TOKEN
   * TODO Check external code call - EXTCALL
   */
    function approve() public override returns(bool){
        require(canApprove(), "You can't withdraw yet");

        Developer memory developer = getDeveloper(msg.sender);

        uint tokens = calcTokens(developer.level);

        satToken.approveWith(msg.sender, tokens);

        setEraMetrics(developer.currentEra, tokens);

        developerNextEra();

        if (canApprove()) approve();

        return true;
    }

    /**
   * @dev Add metrics actions to eras. The metrics are numbers of tokens and developers.
   * @param _era The current era that the develop approve() tokens
   * @param _tokens How much tokens the win to this era
   */
    function setEraMetrics(uint _era, uint _tokens) internal {
        uint oneDev = 1;
        Era memory newEra = Era(_era, _tokens.add(eras[_era].tokens), oneDev.add(eras[_era].developers));
        eras[_era] = newEra;
    }

    /**
   * @dev Allow the dev withdraw tokens from DeveloperPool address to his address
   * TODO Check external code call - EXTCALL
   */
    function withDraw() public override returns(bool){
        satToken.transferFrom(address(this), msg.sender, allowance()); 
        return true;
    }

    /**
   * @dev Show how much tokens the developer can withdraw from DeveloperPool address
   * TODO Check external code call - EXTCALL
   */
    function allowance() public override view returns (uint){
        return satToken.allowance(address(this), msg.sender);
    }

    /**
   * @dev Check if the developer can approve tokens
   */
    function canApprove() internal view returns(bool) {
        Developer memory developer = getDeveloper(msg.sender);

        if (developer.level == 0) return false;

        return canApproveFromPresent(currentBlockNumber(), developer.currentEra) && eraLimit(developer.currentEra);
    }

    /**
   * @dev Check if the limit of eras is the maximum. The state eraMax is the limit
   */
    function eraLimit(uint _currentEra) internal view returns(bool) {
        return _currentEra <= eraMax;
    }

    /**
   * @dev Check if the developer can approve. This funcion check the initial block deploy with the current block
   */
    function canApproveFromPresent(uint _currentBlock, uint _currentEra) internal view returns(bool) {
        return deployedAt.add(blocksPerEra.mul(_currentEra)) <= _currentBlock;
    }

    /**
   * @dev Increment a new era to a developer. This funcions called when the developer approve tokens
   */
    function developerNextEra() internal { 
        developers[msg.sender].currentEra++;
    }

    /**
   * @dev Calc how much tokens the dev can approve
   * @param _level The level of the developer
   */
    function calcTokens(uint _level) internal view returns(uint) {
        uint _levelsSum = uint(levelsSum);
        if (_levelsSum == 0) return 0;
        return _level.mul((tokensPerEra.div(_levelsSum)));
    }

    /**
   * @dev Show how much block missing to approve new tokens
   */
    function nextWithdrawalTime() public view returns(int) {
        Developer memory developer = getDeveloper(msg.sender);

        return int(deployedAt) + (int(blocksPerEra) * int(developer.currentEra)) - int(currentBlockNumber());
    }

    /**
   * @dev Returns the timestamp
   */
    function timestamp() internal view returns(uint) {
        return block.timestamp;
    }

    /**
   * @dev Returns the current block number
   */
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
