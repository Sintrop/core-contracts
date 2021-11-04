// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract ActivistContract {
    struct Activist {
        uint id;
        address activist_wallet; // Hash of wallet
        string role;
        string name;
        string document;
        string document_type;
        ActivistAddress activist_address;
    }
    
    struct ActivistAddress {
        string country;
        string state;
        string city;
        string cep;
    }
    
    Activist[] activistsArray;
    mapping(address => Activist) activists;
    uint public activistsCount;
    
    
    function addActivist( 
        string memory name, 
        string memory document, 
        string memory document_type, 
        string memory country, 
        string memory state, 
        string memory city, 
        string memory cep) public returns(Activist memory) {
            
            uint id = activistsCount + 1;
            string memory role = 'ACTIVIST';
            
            ActivistAddress memory activist_address = ActivistAddress(country, state, city, cep);
            Activist memory activist = Activist(id, msg.sender, name, role, document, document_type, activist_address);
            
            activistsArray.push(activist);
            activists[msg.sender] = activist;
            activistsCount++;
            
            return activist;
    }
    
    function getActivists() public view returns(Activist[] memory) {
        return activistsArray;
    }
    
    function activistExists(address addr) public view returns(bool) {
        bool exists = bytes(activists[addr].name).length > 0;
        return exists;
    }
    
}