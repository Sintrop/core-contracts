pragma solidity >=0.5.0 <=0.9.0;
// SPDX-License-Identifier: GPL-3.0-or-later


/**
* @title UserContract
* @dev This contract work as a centralized user's system, where all users has your userType here
*/
contract UserContract {
    enum UserType { UNDEFINED, PRODUCER, ACTIVIST, RESEARCHER }

    mapping(address => UserType) users;
    uint public usersCount;

    /**
   * @dev Add new user in the system
   * @param addr The address of the user
   * @param userType The type of the user - enum UserType
   */
    function addUser(address addr, UserType userType) public {
        users[addr] = userType;
        usersCount++;
    }

    /**
   * @dev Returns the user type if the user is registered
   * @param addr the user address that want check if exists
   */
    function getUser(address addr) public view returns(UserType) {
        return users[addr];
    }

    /**
   * @dev Returns the enum UserType of the system
   */
    function getUserTypes() public pure returns(string memory, string memory, string memory) {
        return ("PRODUCER", "ACTIVIST", "RESEARCHER");
    }
}