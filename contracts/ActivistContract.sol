// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract ActivistContract {
    struct Activist {
        uint id;
        address activist_wallet; // Hash of wallet
        string role;
        string name;
        string document;
        string documentType;
        bool recentInspection;
        uint totalInspections;
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
    
    /**
   * @dev Allow a new register of activist
   * @param name the name of the activist
   * @param document the document of activist
   * @param documentType the document type type of activist. CPF/CNPJ
   * @param country the country where the activist is
   * @param state the state of the activist
   * @param city the of the activist
   * @param cep the cep of the activist
   * @return a Activist
   */
    function addActivist( 
        string memory name, 
        string memory document, 
        string memory documentType, 
        string memory country, 
        string memory state, 
        string memory city, 
        string memory cep) public returns(Activist memory) {
            
            uint id = activistsCount + 1;
            string memory role = 'ACTIVIST';
            
            ActivistAddress memory activist_address = ActivistAddress(country, state, city, cep);
            Activist memory activist = Activist(id, msg.sender, name, role, document, documentType, false, 0, activist_address);
            
            activistsArray.push(activist);
            activists[msg.sender] = activist;
            activistsCount++;
            
            return activist;
    }
    
    /**
   * @dev Returns all registered activists
   * @return Activist struct array
   */
    function getActivists() public view returns(Activist[] memory) {
        return activistsArray;
    }
    
    /**
   * @dev Check if a specific activist exists
   * @return a bool that represent if a activist exists or not
   */
    function activistExists(address addr) public view returns(bool) {
        bool exists = bytes(activists[addr].name).length > 0;
        return exists;
    }
}