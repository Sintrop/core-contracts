
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Registrable is Ownable {
  mapping(address => bool) public allowedResearcher;

  function newAllowedResearcher(address allowed) public onlyOwner {
    allowedResearcher[allowed] = true;
  }

  modifier mustBeAllowedResearcher() {
    require(allowedResearcher[msg.sender], "Not allowed researcher");
    _;
  }
}
