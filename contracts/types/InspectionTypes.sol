// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

enum InspectionStatus {
  OPEN,
  ACCEPTED,
  INSPECTED,
  EXPIRED
}

struct Inspection {
  uint256 id;
  InspectionStatus status;
  address createdBy;
  address acceptedBy;
  uint256[][] isas;
  int256 isaPoints;
  uint256 createdAt;
  uint256 updatedAt;
}
