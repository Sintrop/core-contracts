// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

interface SatTokenInterface {
    function allowance(address owner, address delegate)
        external
        view
        returns (uint256);

    function approveWith(address delegate, uint256 numTokens)
        external
        returns (uint256);

    function transferFrom(
        address owner,
        address to,
        uint256 numTokens
    ) external returns (bool);
}
