// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract ProducerContract {
    struct Producer {
        uint id;
        address producer_wallet;
        string role;
        string name;
        string document;
        string document_type;
        PropertyAddress property_address;
    }
    
    struct PropertyAddress {
        string country;
        string state;
        string city;
        string cep;
    }
    
    Producer[] producers;
    uint public producersCount;
    
    
    function addProducer( 
        string memory name, 
        string memory document, 
        string memory document_type, 
        string memory country, 
        string memory state, 
        string memory city, 
        string memory cep) public returns(Producer memory) {
            
            uint id = generateId();
            string memory role = 'PRODUCER';
            
            PropertyAddress memory property_address = PropertyAddress(country, state, city, cep);
            Producer memory producer = Producer(id, msg.sender, role, name, document, document_type, property_address);
            
            producers.push(producer);
            producersCount++;
            
            return producer;
    }
    
    function getProducers() public view returns(Producer[] memory) {
        return producers;
    }
    
    function generateId() internal view returns(uint) {
        return producersCount + 1;
    }
}