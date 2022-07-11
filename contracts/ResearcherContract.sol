// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

import "./UserContract.sol";
import "./types/ResearcherTypes.sol";
import "./Registrable.sol";

contract ResearcherContract is Registrable {
  mapping(address => Researcher) internal researchers;

  UserContract internal userContract;
  address[] internal researchersAddress;
  uint256 public researchersCount;

  constructor(address userContractAddress) {
    userContract = UserContract(userContractAddress);
  }

  /**
   * @dev Allow a new register of researcher
   * @param name the name of the researcher
   * @param document the document of researcher
   * @param documentType the document type type of researcher. CPF/CNPJ
   * @param country the country where the researcher is
   * @param state the state of the researcher
   * @param city the of the researcher
   * @param cep the cep of the researcher
   * @return a Researcher
   */
  function addResearcher(
    string memory name,
    string memory document,
    string memory documentType,
    string memory country,
    string memory state,
    string memory city,
    string memory cep
  ) public uniqueResearcher mustBeAllowedUser returns (Researcher memory) {
    uint256 id = researchersCount + 1;
    UserType userType = UserType.RESEARCHER;

    ResearcherAddress memory researcherAddress = ResearcherAddress(country, state, city, cep);

    Researcher memory researcher = Researcher(
      id,
      msg.sender,
      userType,
      name,
      document,
      documentType,
      researcherAddress
    );

    researchers[msg.sender] = researcher;
    researchersAddress.push(msg.sender);
    researchersCount++;
    userContract.addUser(msg.sender, userType);

    return researcher;
  }

  /**
   * @dev Returns all registered researchers
   * @return Researcher struct array
   */
  function getResearchers() public view returns (Researcher[] memory) {
    Researcher[] memory researcherList = new Researcher[](researchersCount);

    for (uint256 i = 0; i < researchersCount; i++) {
      address acAddress = researchersAddress[i];
      researcherList[i] = researchers[acAddress];
    }

    return researcherList;
  }

  /**
   * @dev Return a specific researcher
   * @param addr the address of the researcher.
   */
  function getResearcher(address addr) public view returns (Researcher memory) {
    return researchers[addr];
  }

  /**
   * @dev Check if a specific researcher exists
   * @return a bool that represent if a researcher exists or not
   */
  function researcherExists(address addr) public view returns (bool) {
    return bytes(researchers[addr].name).length > 0;
  }

  // MODIFIERS

  modifier uniqueResearcher() {
    require(!researcherExists(msg.sender), "This researcher already exist");
    _;
  }
}