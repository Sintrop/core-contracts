// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

// import "@openzeppelin/contracts/access/Ownable.sol";
import "./PoolInterface.sol";

import "./SatTokenInterface.sol";
import "./Ownable.sol";

import "./SafeMath.sol";

/**
* @author Everson B. Silva
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

    address[] internal developersAddress;

    SatTokenInterface internal satToken;

    uint public developersCount;

    uint[18] public levelsSumPerEra;

    uint public deployedAt;

    uint public tokensPerEra;

    uint public blocksPerEra;

    uint public eraMax;

    uint public constant blocksPrecision = 5;

    constructor(address _satTokenAddress, uint _tokensPerEra, uint _blocksPerEra, uint _eraMax) {
        satToken = SatTokenInterface(_satTokenAddress);
        deployedAt = currentBlockNumber();
        tokensPerEra = _tokensPerEra.mul(10**18);
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
   * @dev Return the developers address of the system
   */
    function getDevelopersAddress() public view returns(address[] memory) {
        return developersAddress;
    }

    /**
   * @dev Add a new develop to the pool
   * @param _address the address of the developer
   */
    function addDeveloper(address _address) public onlyOwner {
        uint _currentEra = currentContractEra();
        developers[_address] = Developer(_address, 1, _currentEra, timestamp());
        upLevels(_currentEra);
        developersCount++;
        developersAddress.push(_address);
    }

    /**
   * @dev Increment the levels + 1 per era always that a developer is added or the level is up
   * @param _fromEra the era of developer
   */
    function upLevels(uint _fromEra) internal {
        uint[18] memory _levels = levelsSumPerEra;
        uint _eraMax = eraMax;

        for(uint i = _fromEra - 1; i < _eraMax; i++) {
            _levels[i]++;
        }

        levelsSumPerEra = _levels;
    }

    /**
   * @dev Decrement the levels of the undo developer
   * @param _fromEra the era of developer
   */
    function downLevels(uint _fromEra, Developer memory developer) internal {
        uint[18] memory _levels = levelsSumPerEra;
        uint _eraMax = eraMax;

        for(uint i = _fromEra - 1; i < _eraMax; i++) {
            _levels[i] -= developer.level;
        }

        levelsSumPerEra = _levels;
    }

    /**
   * @dev Return the current era of the contract
   */
    function currentContractEra() public view returns(uint) {
        return currentBlockNumber().sub(deployedAt).div(blocksPerEra).add(1);
    }

    /**
   * @dev Increment the level of the develop
   * @param _address the address of the developer
   */
    function addLevel(address _address) public onlyOwner {
        Developer memory developer = getDeveloper(_address);

        developers[_address].level++;
        upLevels(developer.currentEra);
    }

    /**
   * @dev Set to zero the level of the develop
   * @param _address the address of the developer
   */
    function undoLevel(address _address) public onlyOwner {
        Developer memory developer = getDeveloper(_address);
        downLevels(developer.currentEra, developer);
        developers[_address].level = 0;
    }

    /**
   * @dev Allow the developer to approve tokens from DeveloperPool address. DeveloperPool address must have tokens in SAT TOKEN
   * TODO Check external code call - EXTCALL
   */
    function approve() public override returns(bool){
        require(canApprove(), "You can't withdraw yet");

        Developer memory developer = getDeveloper(msg.sender);

        uint tokens = calcTokens(developer.level, developer.currentEra);

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
   * @dev Calc how much tokens the dev can approve in some era
   * @param _level The level of the developer
   * @param _era Era to calc in
   */
    function calcTokens(uint _level, uint _era) internal view returns(uint) {
        uint _levelsSum = levelsSumPerEra[_era - 1];
        if (_levelsSum == 0) return 0;
        return _level.mul((tokensPerEra.div(_levelsSum)));
    }

    /**
   * @dev Show how much block missing to approve new tokens
   */
    function nextApproveTime() public view returns(int) {
        Developer memory developer = getDeveloper(msg.sender);
        return int(deployedAt) + (int(blocksPerEra) * int(developer.currentEra)) - int(currentBlockNumber());
    }

    /**
   * @dev Show how much times the developer can approve tokens. How much eras passed.
   * @return A uint with precision of blocksPrecision state. The real return can be get by return/blocksPrecision and Math.ceil
   */
    function canApproveTimes() public view returns(uint) {
        int approvesTimes = nextApproveTime();
        if (approvesTimes > 0) return 0;

        return uint(-approvesTimes).mul(10**blocksPrecision).div(blocksPerEra);
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
