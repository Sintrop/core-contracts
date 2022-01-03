// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import './UserContract.sol';

/**
* @title ProducerContract
* @dev Producer resource that represent a user that can request a inspection
*/
contract ProducerContract is UserContract {
    struct Producer {
        uint id;
        address producer_wallet;
        UserType userType;
        string name;
        string document;
        string documentType;
        bool recentInspection;
        uint totalRequests;
        uint isaPoints;
        TokenApprove tokenApprove;
        PropertyAddress property_address;
    }
  
    struct TokenApprove {
        uint allowed;
        bool withdrewToken;
    }
    
    struct PropertyAddress {
        string country;
        string state;
        string city;
        string cep;
    }
    
    Producer[] public producersList;
    mapping(address => Producer) producers;
    uint public producersCount;

    /**
   * @dev Allow a new register of producer
   * @param name the name of the producer
   * @param document the document of producer
   * @param documentType the document type type of producer. CPF/CNPJ
   * @param country the country where the producer is
   * @param state the state of the producer
   * @param city the of the producer
   * @param cep the cep of the producer
   */
    function addProducer( 
        string memory name, 
        string memory document, 
        string memory documentType, 
        string memory country, 
        string memory state, 
        string memory city, 
        string memory cep) public returns(bool) {
            
            uint id = producersCount + 1;
            UserType userType = UserType.PRODUCER;
            
            PropertyAddress memory property_address = PropertyAddress(country, state, city, cep);
            TokenApprove memory tokenApprove = TokenApprove(0, false);
            Producer memory producer = Producer(id, msg.sender, userType, name, document, documentType, false, 0, 0, tokenApprove, property_address);
            
            producersList.push(producer);
            producers[msg.sender] = producer;
            producersCount++;
            addUser(msg.sender, userType);
            
            return true;
    }
    
    /**
   * @dev Returns all registered producers
   * @return Producer struct array
   */
    function getProducers() public view returns(Producer[] memory) {
        return producersList;
    }
    
    /**
   * @dev Return a specific producer
   * @param addr the address of the producer.
   */
    function getProducer(address addr) public view returns(Producer memory producer) {
        return producers[addr];
    }
    
    /**
   * @dev Check if a specific producer exists
   * @return a bool that represent if a producer exists or not
   */
    function producerExists(address addr) public view returns(bool) {
        return bytes(producers[addr].name).length > 0;
    }

    function approveProducerNewTokens(address addr, uint numTokens) internal {
        uint tokens = producers[addr].tokenApprove.allowed;
        producers[addr].tokenApprove = TokenApprove(tokens += numTokens, false);
    }

    function getProducerApprove(address address_) public view returns (uint) {
        return producers[address_].tokenApprove.allowed;
    }

    function undoProducerApprove() internal returns (bool) {
        producers[msg.sender].tokenApprove = TokenApprove(0, false);
        return true;
    }
}