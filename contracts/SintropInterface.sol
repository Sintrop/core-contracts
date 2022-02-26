// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

interface SintropInterface {
    function getProducerApprove(address delegate)
        external
        view
        returns (uint256);
}
