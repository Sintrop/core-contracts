// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

import "./ProducerContract.sol";
import "./ActivistContract.sol";
import "./CategoryContract.sol";
import "./types/InspectionTypes.sol";

/**
 * @title SintropContract
 * @dev Sintrop application to certificated a rural producer
 */
contract Sintrop {
  mapping(address => Inspection[]) internal userInspections;
  mapping(uint256 => Inspection) internal inspections;

  ActivistContract public activistContract;
  ProducerContract public producerContract;

  uint256 public inspectionsCount;
  uint256 internal timeBetweenInspections;

  constructor(
    address activistContractAddress,
    address producerContractAddress,
    uint256 timeBetweenInspections_
  ) {
    activistContract = ActivistContract(activistContractAddress);
    producerContract = ProducerContract(producerContractAddress);
    timeBetweenInspections = timeBetweenInspections_;
  }

  /**
   * @dev Allows the current user producer/activist get all yours inspections with status INSPECTED
   */
  function getInspectionsHistory() public view returns (Inspection[] memory) {
    return userInspections[msg.sender];
  }

  /**
   * @dev Allows the current user (producer) request a inspection.
   */
  function requestInspection()
    public
    requireProducer
    requireNoInspectionsOpen
    requireNoRecentInspection
  {
    newRequest();

    producerContract.recentInspection(msg.sender, true);
    producerContract.lastRequestAt(msg.sender, block.number);
  }

  function newRequest() internal {
    uint256[][] memory isas;

    Inspection memory inspection = Inspection(
      inspectionsCount + 1,
      InspectionStatus.OPEN,
      msg.sender,
      msg.sender,
      isas,
      0,
      block.number,
      0
    );
    inspections[inspection.id] = inspection;
    inspectionsCount++;
  }

  /**
   * @dev Allows the current user (activist) accept a inspection.
   * @param inspectionId The id of the inspection that the activist want accept.
   */
  function acceptInspection(uint256 inspectionId)
    public
    requireActivist
    requireInspectionExists(inspectionId)
    returns (bool)
  {
    Inspection memory inspection = inspections[inspectionId];

    require(inspection.status == InspectionStatus.OPEN, "This inspection is not OPEN");

    inspection.status = InspectionStatus.ACCEPTED;
    inspection.updatedAt = block.timestamp;
    inspection.acceptedBy = msg.sender;
    inspections[inspectionId] = inspection;

    activistContract.recentInspection(msg.sender, true);

    return true;
  }

  /**
   * @dev Allow a activist realize a inspection and mark as INSPECTED
   * @param inspectionId The id of the inspection to be realized
   * @param isas The uint[][] of categoryId and isaIndex. Ex: isas = [ [categoryId, isaIndex], [categoryId, isaIndex] ]
   */
  function realizeInspection(uint256 inspectionId, uint256[][] memory isas)
    public
    requireActivist
    requireInspectionExists(inspectionId)
    requireInspectionAccepted(inspectionId)
    requireInspectionOwner(inspectionId)
    returns (bool)
  {
    Inspection memory inspection = inspections[inspectionId];

    markAsRealized(inspection, isas);

    afterRealizeInspection(inspection);

    updateProducerIsa(inspection);

    producerContract.approveProducerNewTokens(inspection.createdBy, 2000);

    return true;
  }

  /**
   * @dev Calculate the ISA of the inspection based in the category and the ISA level of the category
   * @param inspection Receive the inspected inspection with your isas levels
   */
  function calculateIsa(Inspection memory inspection) internal pure returns (int256) {
    uint256[][] memory isas = inspection.isas;
    int256 isaScore = sumIsaScore(isas);
    return isaScore;
  }

  /**
   * @dev Sum the ISA score
   * @param isas The isas values as list of [[categoryId, isaIndex], [categoryId, isaIndex]]
   */
  function sumIsaScore(uint256[][] memory isas) internal pure returns (int256) {
    int256[5] memory points = [int256(10), int256(5), int256(0), int256(-5), int256(-10)];
    int256 isaScore = 0;

    for (uint8 i = 0; i < isas.length; i++) {
      uint256 isaIndex = isas[i][1];
      isaScore += points[isaIndex];
    }
    return isaScore;
  }

  function markAsRealized(Inspection memory inspection, uint256[][] memory isas) internal {
    inspection.isas = isas;
    inspection.status = InspectionStatus.INSPECTED;
    inspection.updatedAt = block.timestamp;
    inspection.isaScore = calculateIsa(inspection);
    inspections[inspection.id] = inspection;
  }

  function updateProducerIsa(Inspection memory inspection) internal {
    producerContract.updateIsaScore(inspection.createdBy, inspection.isaScore);
  }

  /**
   * @dev Returns a inspection by id if that exists.
   * @param id The id of the inspection to return.
   */
  function getInspection(uint256 id) public view returns (Inspection memory) {
    return inspections[id];
  }

  /**
   * @dev Returns all requested inspections.
   */
  function getInspections() public view returns (Inspection[] memory) {
    Inspection[] memory inspectionsList = new Inspection[](inspectionsCount);

    for (uint256 i = 0; i < inspectionsCount; i++) {
      inspectionsList[i] = inspections[i + 1];
    }

    return inspectionsList;
  }

  /**
   * @dev Returns all inpections status string.
   */
  function getInspectionsStatus()
    public
    pure
    returns (
      string memory,
      string memory,
      string memory,
      string memory
    )
  {
    return ("OPEN", "ACCEPTED", "INSPECTED", "EXPIRED");
  }

  /**
   * @dev Check if an inspections exists in mapping.
   * @param id The id of the inspection that the activist want accept.
   */
  function inspectionExists(uint256 id) public view returns (bool) {
    return inspections[id].id >= 1;
  }

  /**
   * @dev Inscrement producer and activist request action and mark both as no recent open requests and inspection
   * @param inspection the inspected inspection
   */
  function afterRealizeInspection(Inspection memory inspection) internal {
    address createdBy = inspection.createdBy;
    address acceptedBy = inspection.acceptedBy;

    // Increment actvist inspections and release to carry out new inspections
    activistContract.recentInspection(acceptedBy, false);
    activistContract.incrementRequests(acceptedBy);

    // Increment producer requests and release to carry out new requests
    producerContract.recentInspection(createdBy, false);
    producerContract.incrementRequests(createdBy);

    userInspections[createdBy].push(inspection);
    userInspections[acceptedBy].push(inspection);
  }

  function isActivistOwner(uint256 inspectionId) internal view returns (bool) {
    return inspections[inspectionId].acceptedBy == msg.sender;
  }

  function isAccepted(uint256 inspectionId) internal view returns (bool) {
    return inspections[inspectionId].status == InspectionStatus.ACCEPTED;
  }

  function canRequestInspection() public view returns (bool) {
    Producer memory producer = producerContract.getProducer(msg.sender);

    uint256 lastRequestAt = producer.lastRequestAt;
    bool canRequest = block.number > lastRequestAt + timeBetweenInspections;

    return canRequest || lastRequestAt == 0;
  }

  // MODIFIERS

  modifier requireActivist() {
    require(activistContract.activistExists(msg.sender), "Please register as activist");
    _;
  }

  modifier requireInspectionExists(uint256 inspectionId) {
    require(inspectionExists(inspectionId), "This inspection don't exists");
    _;
  }

  modifier requireProducer() {
    require(producerContract.producerExists(msg.sender), "Please register as producer");
    _;
  }

  modifier requireNoInspectionsOpen() {
    require(!producerContract.getProducer(msg.sender).recentInspection, "Request OPEN or ACCEPTED");
    _;
  }

  modifier requireNoRecentInspection() {
    require(canRequestInspection(), "Recent inspection");
    _;
  }

  modifier requireInspectionAccepted(uint256 inspectionId) {
    require(isAccepted(inspectionId), "Accept this inspection before");
    _;
  }

  modifier requireInspectionOwner(uint256 inspectionId) {
    require(isActivistOwner(inspectionId), "You not accepted this inspection");
    _;
  }
}
