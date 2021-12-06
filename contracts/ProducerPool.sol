pragma solidity >=0.7.0 <=0.9.0;
// SPDX-License-Identifier: GPL-3.0-or-later

interface SatTokenInterface {
    function producerFundsAddress() external view returns(address);
    function allowance(address owner, address delegate) external view returns(uint);
    function approveWith(address from, address delegate) external returns(uint);
}

contract ProducerPool {
    SatTokenInterface satToken;

    constructor(address satTokenAddress) {
        satToken = SatTokenInterface(satTokenAddress);
    }

    function approve() public returns(uint) {
        uint numTokens = satToken.approveWith(fundAddress(), msg.sender);
        return numTokens;
    }

    function withDraw() public returns(bool) {
    }

    function allowance() public view returns (uint) {
        return satToken.allowance(fundAddress(), msg.sender);
    }

    function fundAddress() internal view returns(address) {
        return satToken.producerFundsAddress();
    }
}