// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

import "./PoolInterface.sol";
import "./SintropInterface.sol";
import "./SatTokenInterface.sol";

contract ProducerPool is PoolInterface {
    SatTokenInterface satToken;
    SintropInterface sintrop;

    constructor(address satTokenAddress, address sintropAddress) {
        satToken = SatTokenInterface(satTokenAddress);
        sintrop = SintropInterface(sintropAddress);
    }

    function approve() public override returns (bool) {
        uint256 numTokens = sintrop.getProducerApprove(msg.sender);

        satToken.approveWith(msg.sender, numTokens);
        return true;
    }

    function withDraw() public override returns (bool) {
        satToken.transferFrom(address(this), msg.sender, allowance());
        return true;
    }

    function allowance() public view override returns (uint256) {
        return satToken.allowance(address(this), msg.sender);
    }
}
