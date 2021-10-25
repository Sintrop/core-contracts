pragma solidity ^0.8.0;
// SPDX-License-Identifier: GPL-3.0-or-later


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract SATtoken is ERC20 {
    string public SYMBOL = "SAT";
    string public NAME = "SUSTAINABLE AGRICULTURE TOKEN";
    uint8 public DECIMALS = 8;
    uint256 public INITIAL_SUPPLY = 1500000000000000000000000000;
    
    constructor() ERC20(NAME, SYMBOL) {
    _mint(msg.sender, INITIAL_SUPPLY);
    // alocar proprieamente o initial supply conforme paper
    }
    
    function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
    ) internal override(ERC20) {}
    
    
    function approveProducer() private {
        // requer average ISA > 10 
        // requer mínimo de inspeções = 2 
        // aprovar
    }
    
    function approveActivist() private {
        // requer average ISA > 10 
        // requer mínimo de inspeções = 2 
        // aprovar
    }
    
    function addToPoolProducer() public {
        // requer produtor aprovado
        // 
    }
    
}
