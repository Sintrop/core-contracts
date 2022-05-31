// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

import "./PoolInterface.sol";
import "./SacTokenInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./types/DeveloperPoolTypes.sol";
import "./Blockable.sol";

/**
 * @author Everson B. Silva
 * @title DeveloperContract
 * @dev DeveloperPool is a contract to reward developers
 */
contract DeveloperPool is Ownable, Blockable, PoolInterface {
  using SafeMath for uint256;

  mapping(address => Developer) internal developers;
  mapping(uint256 => Era) public eras;

  address[] internal developersAddress;
  uint256 public developersCount;
  uint256[18] public levelsSumPerEra;
  uint256 public tokensPerEra;

  SacTokenInterface internal sacToken;

  constructor(
    address _sacTokenAddress,
    uint256 _tokensPerEra,
    uint256 _blocksPerEra,
    uint256 _eraMax
  ) Blockable(_blocksPerEra, _eraMax) {
    sacToken = SacTokenInterface(_sacTokenAddress);
    tokensPerEra = _tokensPerEra.mul(10**18);
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
  function getDevelopersAddress() public view returns (address[] memory) {
    return developersAddress;
  }

  /**
   * @dev Add a new develop to the pool
   * @param _address the address of the developer
   */
  function addDeveloper(address _address) public onlyOwner {
    uint256 _currentEra = currentContractEra();
    developers[_address] = Developer(_address, 1, _currentEra, block.timestamp);
    upLevels(_currentEra);
    developersCount++;
    developersAddress.push(_address);
  }

  /**
   * @dev Increment the levels + 1 per era always that a developer is added or the level is up
   * @param _fromEra the era of developer
   */
  function upLevels(uint256 _fromEra) internal {
    uint256[18] memory _levels = levelsSumPerEra;
    uint256 _eraMax = eraMax;

    for (uint256 i = _fromEra - 1; i < _eraMax; i++) {
      _levels[i]++;
    }

    levelsSumPerEra = _levels;
  }

  /**
   * @dev Decrement the levels of the undo developer
   * @param _fromEra the era of developer
   */
  function downLevels(uint256 _fromEra, Developer memory developer) internal {
    uint256[18] memory _levels = levelsSumPerEra;
    uint256 _eraMax = eraMax;

    for (uint256 i = _fromEra - 1; i < _eraMax; i++) {
      _levels[i] -= developer.level;
    }

    levelsSumPerEra = _levels;
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
   * @dev Allow the developer to approve tokens from DeveloperPool address. DeveloperPool address must have tokens in SAC TOKEN
   * TODO Check external code call - EXTCALL
   */
  function approve() public override mustBeAbleToApprove returns (bool) {
    Developer memory developer = getDeveloper(msg.sender);

    uint256 tokens = calcTokens(developer.level, developer.currentEra);

    sacToken.approveWith(msg.sender, tokens);

    setEraMetrics(developer.currentEra, tokens);

    developerNextEra();

    if (canApprove(developer.currentEra + 1)) approve();

    return true;
  }

  /**
   * @dev Add metrics actions to eras. The metrics are numbers of tokens and developers.
   * @param _era The current era that the develop approve() tokens
   * @param _tokens How much tokens the win to this era
   */
  function setEraMetrics(uint256 _era, uint256 _tokens) internal {
    uint256 oneDev = 1;
    Era memory newEra = Era(
      _era,
      _tokens.add(eras[_era].tokens),
      oneDev.add(eras[_era].developers)
    );
    eras[_era] = newEra;
  }

  /**
   * @dev Allow the dev withdraw tokens from DeveloperPool address to his address
   * TODO Check external code call - EXTCALL
   */
  function withDraw() public override returns (bool) {
    sacToken.transferFrom(address(this), msg.sender, allowance());
    return true;
  }

  /**
   * @dev Show how much tokens the developer can withdraw from DeveloperPool address
   * TODO Check external code call - EXTCALL
   */
  function allowance() public view override returns (uint256) {
    return sacToken.allowance(address(this), msg.sender);
  }

  /**
   * @dev Increment a new era to a developer. This funcions called when the developer approve tokens
   */
  function developerNextEra() internal {
    developers[msg.sender].currentEra++;
  }

  function currentDeveloper() internal view returns (Developer memory) {
    return developers[msg.sender];
  }

  /**
   * @dev Calc how much tokens the dev can approve in some era
   * @param _level The level of the developer
   * @param _era Era to calc in
   */
  function calcTokens(uint256 _level, uint256 _era) internal view returns (uint256) {
    uint256 _levelsSum = levelsSumPerEra[_era - 1];
    if (_levelsSum == 0) return 0;
    return _level.mul((tokensPerEra.div(_levelsSum)));
  }

  // MODIFIERS

  modifier mustBeAbleToApprove() {
    require(canApprove(currentDeveloper().currentEra), "You can't withdraw yet");
    _;
  }
}
