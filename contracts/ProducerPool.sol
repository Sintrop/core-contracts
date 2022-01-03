pragma solidity >=0.7.0 <=0.9.0;
// SPDX-License-Identifier: GPL-3.0-or-later

import "./PoolInterface.sol";

interface SintropInterface {
    function getProducerApprove(address delegate) external view returns(uint);
}

interface SatTokenInterface {
    function allowance(address owner, address delegate) external view returns(uint);
    function approveWith(address delegate, uint numTokens) external returns(uint);
    function transferFrom(address owner, address to, uint numTokens) external returns(bool);
}

contract ProducerPool is PoolInterface {
    SatTokenInterface satToken;
    SintropInterface sintrop;

    constructor(address satTokenAddress, address sintropAddress) {
        satToken = SatTokenInterface(satTokenAddress);
        sintrop = SintropInterface(sintropAddress);
    }

    function approve() public override returns(bool) {
        uint numTokens = sintrop.getProducerApprove(msg.sender);

        satToken.approveWith(msg.sender, numTokens);
        return true;
    }

    function withDraw() public override returns(bool){
        satToken.transferFrom(address(this), msg.sender, allowance()); 
        return true;
    }

    function allowance() public view override returns (uint) {
        return satToken.allowance(address(this), msg.sender);
    }
}