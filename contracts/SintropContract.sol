pragma solidity >=0.5.0 <=0.9.0;
// SPDX-License-Identifier: GPL-3.0-or-later

import './InspectionContract.sol';

contract Ownable {}
contract SATtoken {}

/**
* @title SintropContract
* @dev Sintrop application to certificated a rural producer
*/
contract SintropContract is InspectionContract, SATtoken, Ownable {}