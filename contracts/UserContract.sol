// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./types/UserTypes.sol";
import "./Callable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title UserContract
 * @dev This contract work as a centralized user's system, where all users has your userType here
 */
contract UserContract is Ownable, Callable {
  
  mapping(address => UserType) internal users;
  mapping(uint => Delation) private idToDelation;

  using Counters for Counters.Counter;
  Counters.Counter private _delationIds;
  uint256 public usersCount;
  

  struct Delation {
    uint id;
    address informer;
    address reported;
    string title;
    string testimony;
    string proofPhoto;
  }

  /**
   * @dev Add new user in the system
   * @param addr The address of the user
   * @param userType The type of the user - enum UserType
   */
  function addUser(address addr, UserType userType) public mustBeAllowedCaller mustNotExists(addr) mustBeValidType(userType) {
    users[addr] = userType;
    usersCount++;
  }

  /**
   * @dev Returns the user type if the user is registered
   * @param addr the user address that want check if exists
   */
  function getUser(address addr) public view returns (UserType) {
    return users[addr];
  }

  /**
   * @dev Returns the enum UserType of the system
   */
  function userTypes()
    public
    pure
    returns (
      string memory,
      string memory,
      string memory,
      string memory,
      string memory,
      string memory,
      string memory,
      string memory
    )
  {
    return (
      "UNDEFINED",
      "PRODUCER",
      "ACTIVIST",
      "RESEARCHER",
      "DEVELOPER",
      "ADVISOR",
      "CONTRIBUTOR",
      "INVESTOR"
    );
  }

  /**
   * @dev Add new delation in the system
   * @param addr The address of the user
   * @param title Title the delation 
   * @param testimony Content the delation
   * @param proofPhoto Photo proof the delation
   */
  function createDelation(address addr, string memory title, string memory testimony, string memory proofPhoto) public {
    _delationIds.increment();
    uint delationId = _delationIds.current();
    Delation storage delation = idToDelation[delationId];
    delation.id = delationId;
    delation.informer = msg.sender;
    delation.reported = addr;
    delation.title = title;
    delation.testimony = testimony;
    delation.proofPhoto = proofPhoto;
  }

  /**
   * @dev fetches all delations
   */
  function fetchDelations() public view returns (Delation[] memory) {
    uint itemCount = _delationIds.current();
    
    Delation[] memory delations = new Delation[](itemCount);
    for (uint i = 0; i < itemCount; i++) {
      uint currentId = i + 1;
      Delation storage currentItem = idToDelation[currentId];
      delations[i] = currentItem;  
    }
    return delations;
  }

  // MODIFIER

  modifier mustNotExists(address addr) {
    require(users[addr] == UserType.UNDEFINED, "User already exists");
    _;
  }

  /**
   * @dev Modifier to check if user type is UNDEFINED when register
   */
  modifier mustBeValidType(UserType userType) {
    require(userType != UserType.UNDEFINED, "Invalid user type");
     _;
  }
}
