
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Callable is Ownable {
  mapping(address => bool) public allowedCaller;

  function newAllowedCaller(address allowed) public onlyOwner {
    allowedCaller[allowed] = true;
  }

  modifier mustBeAllowedCaller() {
    require(allowedCaller[msg.sender], "Not allowed caller");
    _;
  }
}
