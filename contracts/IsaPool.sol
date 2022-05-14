// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

import "./PoolPassiveInterface.sol";
import "./SacTokenInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @author Sintrop
 * @title IsaPool
 * @dev IsaPool is a contract to manage user votes
 */
contract IsaPool is PoolPassiveInterface, Ownable {
  address allowedCaller;
  SacTokenInterface internal sacToken;

  constructor(address sacTokenAddress) {
    sacToken = SacTokenInterface(sacTokenAddress);
  }

  function changeAllowedCaller(address allowed) public onlyOwner returns (bool) {
    allowedCaller = allowed;
    return true;
  }

  /**
   * @dev Show how much tokens the developer can withdraw from DeveloperPool address
   * @return uint256
   * TODO Check external code call - EXTCALL
   */
  function allowance() public view override returns (uint256) {
    return sacToken.allowance(address(this), msg.sender);
  }

  /**
   * @dev Allow a user know how much SAC Tokens has
   * @param tokenOwner The address of the token owner
   * @return uint256
   */
  function balanceOf(address tokenOwner) public view override returns (uint256) {
    return sacToken.balanceOf(tokenOwner);
  }

  /**
   * @dev Allow a user know how much SAC Tokens this pool has
   */
  function balance() public view override returns (uint256) {
    return balanceOf(address(this));
  }

  /**
   * @dev Allow a user approve some tokens from pool to he
   * @param _numTokens How much tokens the user want transfer
   * @return bool
   */
  function approveWith(address delegate, uint256 _numTokens)
    public
    override
    mustBeAllowedCaller
    returns (bool)
  {
    sacToken.approveWith(delegate, _numTokens);
    return true;
  }

  function withDraw() public pure override returns (bool) {
    return true;
  }

  /**
   * @dev Allow a user transfer some tokens to this contract pool
   * @param tokenOwner The address of the token owner
   * @param numTokens How much tokens the user want transfer
   * @return bool
   */
  function transferWith(address tokenOwner, uint256 numTokens) public override returns (bool) {
    sacToken.transferWith(tokenOwner, numTokens);
    return true;
  }

  modifier mustBeAllowedCaller() {
    require(allowedCaller == msg.sender, "Not allowed caller");
    _;
  }
}
