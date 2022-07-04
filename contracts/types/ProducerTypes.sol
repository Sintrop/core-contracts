// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

import "./UserTypes.sol";

struct Producer {
  uint256 id;
  address producerWallet;
  UserType userType;
  string name;
  string document;
  string documentType;
  bool recentInspection;
  uint256 totalRequests;
  int256 isaScore;
  uint256 lastRequestAt;
  TokenApprove tokenApprove;
  PropertyAddress propertyAddress;
}

struct TokenApprove {
  uint256 allowed;
  bool withdrewToken;
}

struct PropertyAddress {
  string country;
  string state;
  string city;
  string cep;
}
