pragma solidity >=0.5.0 <=0.9.0;
// SPDX-License-Identifier: GPL-3.0-or-later

import './ProducerContract.sol';
import './ActivistContract.sol';
import './CategoryContract.sol';


/**
* @title InspectionContract
* @dev Inpection action core
*/
contract InspectionContract is ProducerContract, ActivistContract, CategoryContract {
    enum InspectionStatus { OPEN, EXPIRED, INSPECTED, ACCEPTED } 
    uint inspactionExpireIn = 604800; // Seven days
    
    struct Inspection {
        uint id;
        InspectionStatus status;
        address producerWallet;
        address activistWallet;
        uint[][] isas;
        uint isaAverage;
        uint expiresIn;
        uint createdAt;
        uint index;
    }
    
    Inspection[] inspectionsArray;
    mapping(address => Inspection[]) userInspections;
    mapping(uint256 => Inspection) inspections;
    uint256 inspectionsCount;
    
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
        require(producerExists(msg.sender), "You are not a producer! Please register as one");
        Producer memory producer = producers[msg.sender];
        require(producer.recentInspection == false, "You have a inspection request OPEN or ACCEPTED! Wait a activist realize inspection or you can close it");
        
        createRequest();
        producers[msg.sender].recentInspection = true;
        
        return true;
    }  
    
    
    function createRequest() internal{
        uint id = inspectionsCount + 1;
        uint index = id - 1;
        uint[][] memory isas;
        uint expiresIn = block.timestamp + inspactionExpireIn;
        Inspection memory inspection = Inspection(id, InspectionStatus.OPEN, msg.sender, msg.sender, isas,  0, expiresIn,  block.timestamp, index);
        inspectionsArray.push(inspection);
        inspections[id] = inspection;
        inspectionsCount++;
    }
    
    /**
   * @dev Allows the current user (activist) accept a inspection.
   * @param inspectionId The id of the inspection that the activist want accept.
   */
    function acceptInspection(uint inspectionId) public requireActivist requireInspectionExists(inspectionId) returns(bool) {
        Inspection memory inspection = inspections[inspectionId];
        if (inspection.status == InspectionStatus.OPEN) {
            // Updated inspection in mapping
            inspection.status = InspectionStatus.ACCEPTED;
            inspection.activistWallet = msg.sender;
            inspections[inspectionId] = inspection;

            // Updated inspection in array
            inspectionsArray[inspection.index].status = InspectionStatus.ACCEPTED;
            inspectionsArray[inspection.index].activistWallet = msg.sender;

            return true;
        }
        else {
            return false;
        }
    }  
    
    function calculateIsa(Inspection memory inspection) internal pure returns(uint){
        uint16[5] memory isasValue = [10000, 1000, 100, 10, 1];
        
        uint[][] memory isas = inspection.isas;
        uint isaSum = 0;
        for (uint8 i = 0; i < isas.length; i++) {
            uint isaIndex = isas[i][1];
            isaSum += isasValue[isaIndex];
            
        }
        return isaSum / isas.length;
    }
    
    /**
     * @dev Allow a activist realize a inspection and mark as INSPECTED
     * @param inspectionId The id of the inspection to be realized
     * @param isas The uint[][] of categoryId and isaIndex. Ex: isas = [ [categoryId, isaIndex], [categoryId, isaIndex] ]
     */ 
    function realizeInspection(uint inspectionId, uint[][] memory isas) public requireActivist requireInspectionExists(inspectionId) returns(bool) {
        if (inspections[inspectionId].status != InspectionStatus.ACCEPTED) return false;
        if (inspections[inspectionId].activistWallet != msg.sender) return false;
        
        inspections[inspectionId].isas = isas;
        inspections[inspectionId].status = InspectionStatus.INSPECTED;
        inspections[inspectionId].isaAverage = calculateIsa(inspections[inspectionId]);
        afterRealizeInspection(inspectionId);

        inspectionsArray[inspections[inspectionId].index].status = InspectionStatus.INSPECTED;

        return true;
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
    function getRequestedInspections() public view returns (Inspection[] memory) {
        return inspectionsArray;
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
   * @param inspectionId The id of the inspection
   */
    function afterRealizeInspection(uint inspectionId) internal {
        address producerWallet = inspections[inspectionId].producerWallet;
        address activistWallet = inspections[inspectionId].activistWallet;
        
        // Increment actvist inspections and release to carry out new inspections
        activists[activistWallet].recentInspection = false;
        activists[activistWallet].totalInspections++;
        
        // Increment producer requests and release to carry out new requests
        producers[producerWallet].recentInspection = false;
        producers[producerWallet].totalRequests++;
        
        userInspections[producerWallet].push(inspections[inspectionId]);
        userInspections[activistWallet].push(inspections[inspectionId]);
    }
    
    
    // MODIFIERS
    modifier requireActivist() {
        require(activistExists(msg.sender), "You must be an activist! Please register as one");
        _;
    }
    
    modifier requireInspectionExists(uint inspectionId) {
        require(inspectionExists(inspectionId), "This inspection don't exists");
        _;
    }
    
}
