// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

import "./UserContract.sol";

contract ActivistContract is UserContract {
    struct Activist {
        uint256 id;
        address activistWallet;
        UserType userType;
        string name;
        string document;
        string documentType;
        bool recentInspection;
        uint256 totalInspections;
        ActivistAddress activistAddress;
    }

    struct ActivistAddress {
        string country;
        string state;
        string city;
        string cep;
    }

    mapping(address => Activist) internal activists;
    address[] internal activistsAddress;
    uint256 public activistsCount;

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
        string memory cep
    ) public returns (Activist memory) {
        require(!activistExists(msg.sender), "This activist already exist");
        uint256 id = activistsCount + 1;
        UserType userType = UserType.ACTIVIST;

        ActivistAddress memory activistAddress = ActivistAddress(
            country,
            state,
            city,
            cep
        );
        Activist memory activist = Activist(
            id,
            msg.sender,
            userType,
            name,
            document,
            documentType,
            false,
            0,
            activistAddress
        );

        activists[msg.sender] = activist;
        activistsAddress.push(msg.sender);
        activistsCount++;
        addUser(msg.sender, userType);

        return activist;
    }

    /**
     * @dev Returns all registered activists
     * @return Activist struct array
     */
    function getActivists() public view returns (Activist[] memory) {
        Activist[] memory activistList = new Activist[](activistsCount);

        for(uint i = 0; i < activistsCount; i++){
            address acAddress = activistsAddress[i];
            activistList[i]= activists[acAddress];
        }

        return activistList;
    }

    /**
     * @dev Return a specific activist
     * @param addr the address of the activist.
     */
    function getActivist(address addr) public view returns (Activist memory) {
        return activists[addr];
    }

    /**
     * @dev Check if a specific activist exists
     * @return a bool that represent if a activist exists or not
     */
    function activistExists(address addr) public view returns (bool) {
        return bytes(activists[addr].name).length > 0;
    }
}
