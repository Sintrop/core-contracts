
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Registrable is Ownable {
  mapping(address => bool) public allowedUser;

  function newAllowedUser(address allowed) public onlyOwner {
    allowedUser[allowed] = true;
  }

  modifier mustBeAllowedUser() {
    require(allowedUser[msg.sender], "Not allowed user");
    _;
  }
}
