// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

enum UserType {
  PRODUCER,
  ACTIVIST,
  RESEARCHER,
  DEVELOPER,
  ADVISER,
  CONTRIBUTOR,
  INVESTOR
}

interface UserInterface {
  function addUser(address addr, UserType userType) external;
}
