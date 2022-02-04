// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

interface PoolInterface {
    function approve() external  returns(bool);
    function withDraw() external returns(bool);
    function allowance() external view returns (uint);
}