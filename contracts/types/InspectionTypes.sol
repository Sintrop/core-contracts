// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

enum InspectionStatus {
  OPEN,
  EXPIRED,
  INSPECTED,
  ACCEPTED
}

struct Inspection {
  uint256 id;
  InspectionStatus status;
  address producerWallet;
  address activistWallet;
  uint256[][] isas;
  int256 isaPoints;
  uint256 expiresIn;
  uint256 createdAt;
  uint256 updatedAt;
}
