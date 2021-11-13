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
    }
    
    Inspection[] inspectionsArray;
    mapping(uint256 => Inspection) inspections;
    uint256 inspectionsCount;

  /**
   * @dev Allows the current user (producer) request a inspection.
   */
    function requestInspection() public {
        require(producerExists(msg.sender), "You are not a producer! Please register as one");
        
        uint id = inspectionsCount + 1;
        
        uint[][] memory isas;
        uint expiresIn = block.timestamp + inspactionExpireIn;
        Inspection memory inspection = Inspection(id, InspectionStatus.OPEN, msg.sender, msg.sender, isas,  0, expiresIn,  block.timestamp);
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
            inspection.status = InspectionStatus.ACCEPTED;
            inspection.activistWallet = msg.sender;
            inspections[inspectionId] = inspection;
            return true;
        }
        else {
            return false;
        }
    }  
    
    function calculateIsa(Inspection memory inspection) public returns(uint){
        //atribui um nota para cada nível de sustentabilidade
        //faz a média utilizando as categorias mais votadas
        //retorna o ISA
    }
    
    /**
     * @dev Allow a activist realize a inspection and mark as INSPECTED
     * @param inspectionId The id of the inspection to be realized
     * @param isas The uint[][] of categoryId and isaIndex. Ex: isas = [ [categoryId, isaIndex], [categoryId, isaIndex] ]
     */ 
    function realizeInspection(uint inspectionId, uint[][] memory isas) public requireActivist requireInspectionExists(inspectionId) returns(bool) {
        if (inspections[inspectionId].status == InspectionStatus.ACCEPTED) return false;
        if (inspections[inspectionId].activistWallet != msg.sender) return false;
        
        inspections[inspectionId].isas = isas;
        inspections[inspectionId].status = InspectionStatus.INSPECTED;
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
   * @dev Returns all request inspections.
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














