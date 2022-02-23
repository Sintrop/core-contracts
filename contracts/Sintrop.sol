// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

import "./ProducerContract.sol";
import "./ActivistContract.sol";
import "./CategoryContract.sol";

/**
* @title SintropContract
* @dev Sintrop application to certificated a rural producer
*/
contract Sintrop is ProducerContract, ActivistContract, CategoryContract {
    enum InspectionStatus { OPEN, EXPIRED, INSPECTED, ACCEPTED }
    uint inspactionExpireIn = 604800;

    struct Inspection {
        uint id;
        InspectionStatus status;
        address producerWallet;
        address activistWallet;
        uint[][] isas;
        int isaPoints;
        uint expiresIn;
        uint createdAt;
        uint updatedAt;
        uint index;
    }
    Inspection[] inspectionsList;
    mapping(address => Inspection[]) userInspections;
    mapping(uint256 => Inspection) inspections;
    uint256 public inspectionsCount;

    /**
   * @dev Allows the current user producer/activist get all yours inspections with status INSPECTED
   */
    function getInspectionsHistory() public view returns(Inspection[] memory) {
        return userInspections[msg.sender];
    }

  /**
   * @dev Allows the current user (producer) request a inspection.
   */
    function requestInspection() public returns(bool) {
        require(producerExists(msg.sender), "Please register as producer");
        require(!producers[msg.sender].recentInspection, "You have a inspection request OPEN or ACCEPTED");

        createRequest();
        producers[msg.sender].recentInspection = true;

        return true;
    }

    function createRequest() internal{
        uint id = inspectionsCount + 1;
        uint index = id - 1;
        uint[][] memory isas;
        uint expiresIn = block.timestamp + inspactionExpireIn;
        Inspection memory inspection = Inspection(id, InspectionStatus.OPEN, msg.sender, msg.sender, isas,
        0, expiresIn,  block.timestamp, 0, index);
        inspectionsList.push(inspection);
        inspections[id] = inspection;
        inspectionsCount++;
    }

    /**
   * @dev Allows the current user (activist) accept a inspection.
   * @param inspectionId The id of the inspection that the activist want accept.
   */
    function acceptInspection(uint inspectionId) public
    requireActivist requireInspectionExists(inspectionId) returns(bool) {
        Inspection memory inspection = inspections[inspectionId];

        require(inspection.status == InspectionStatus.OPEN, "This inspection is not OPEN");

        inspection.status = InspectionStatus.ACCEPTED;
        inspection.updatedAt = block.timestamp;
        inspection.activistWallet = msg.sender;
        inspections[inspectionId] = inspection;

        activists[msg.sender].recentInspection = true;

        inspectionsList[inspection.index] = inspection;
        return true;
    }

    /**
     * @dev Allow a activist realize a inspection and mark as INSPECTED
     * @param inspectionId The id of the inspection to be realized
     * @param isas The uint[][] of categoryId and isaIndex. Ex: isas = [ [categoryId, isaIndex], [categoryId, isaIndex] ]
     */
    function realizeInspection(uint inspectionId, uint[][] memory isas)
      public  requireActivist requireInspectionExists(inspectionId) returns(bool) {
        require(isAccepted(inspectionId), "Accept this inspection before");
        require(isActivistOwner(inspectionId), "You not accepted this inspection");

        Inspection memory inspection = inspections[inspectionId];

        markAsRealized(inspection, isas);

        afterRealizeInspection(inspection);

        updateProducerIsa(inspection);

        approveProducerNewTokens(inspection.producerWallet, 2000);

        return true;
    }

  /**
   * @dev Calculate the ISA of the inspection based in the category and the ISA level of the category
   * @param inspection Receive the inspected inspection with your isas levels
   */
    function calculateIsa(Inspection memory inspection) internal pure returns(int){
        uint[][] memory isas = inspection.isas;
        int isaPoints = sumIsaPoints(isas);
        return isaPoints;
    }

  /**
   * @dev Sum the ISA points
   * @param isas The isas values as list of [[categoryId, isaIndex], [categoryId, isaIndex]]
   */
    function sumIsaPoints(uint[][] memory isas) internal pure returns(int) {
        int[5] memory points = [int(10), int(5), int(0), int(-5), int(-10)];
        int isaPoints = 0;

        for (uint8 i = 0; i < isas.length; i++) {
            uint isaIndex = isas[i][1];
            isaPoints += points[isaIndex];
        }
        return isaPoints;
    }

    function markAsRealized(Inspection memory inspection, uint[][] memory isas) internal {
        inspection.isas = isas;
        inspection.status = InspectionStatus.INSPECTED;
        inspection.updatedAt = block.timestamp;
        inspection.isaPoints = calculateIsa(inspection);
        inspections[inspection.id] = inspection;
        inspectionsList[inspection.index] = inspection;
    }

    function updateProducerIsa(Inspection memory inspection) internal {
        producers[inspection.producerWallet].isaPoints = inspection.isaPoints;
    }

    /**
   * @dev Returns a inspection by id if that exists.
   * @param id The id of the inspection to return.
   */
    function getInspection(uint256 id) public view returns(Inspection memory) {
        return inspections[id];
    }

    /**
   * @dev Returns all requested inspections.
   */
    function getInspections() public view returns (Inspection[] memory) {
        return inspectionsList;
    }

    /**
   * @dev Returns all inpections status string.
   */
    function getInspectionsStatus() public pure returns(string memory, string memory, string memory, string memory) {
        return ("OPEN", "EXPIRED", "INSPECTED", "ACCEPTED");
    }

    /**
   * @dev Check if an inspections exists in mapping.
   * @param id The id of the inspection that the activist want accept.
   */
    function inspectionExists(uint256 id) public view returns(bool) {
        return inspections[id].id >= 1;
    }

    /**
   * @dev Inscrement producer and activist request action and mark both as no recent open requests and inspection
   * @param inspection the inspected inspection
   */
    function afterRealizeInspection(Inspection memory inspection) internal {
        address producerWallet = inspection.producerWallet;
        address activistWallet = inspection.activistWallet;

        // Increment actvist inspections and release to carry out new inspections
        activists[activistWallet].recentInspection = false;
        activists[activistWallet].totalInspections++;

        // Increment producer requests and release to carry out new requests
        producers[producerWallet].recentInspection = false;
        producers[producerWallet].totalRequests++;

        userInspections[producerWallet].push(inspection);
        userInspections[activistWallet].push(inspection);
    }

    function isActivistOwner(uint inspectionId) internal view returns(bool) {
        return inspections[inspectionId].activistWallet == msg.sender;
    }

    function isAccepted(uint inspectionId) internal view returns(bool) {
        return inspections[inspectionId].status == InspectionStatus.ACCEPTED;
    }

    // MODIFIERS
    modifier requireActivist() {
        require(activistExists(msg.sender), "Please register as activist");
        _;
    }

    modifier requireInspectionExists(uint inspectionId) {
        require(inspectionExists(inspectionId), "This inspection don't exists");
        _;
    }
}
