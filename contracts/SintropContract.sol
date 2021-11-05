pragma solidity >=0.5.0 <=0.9.0;
// SPDX-License-Identifier: GPL-3.0-or-later

import './ProducerContract.sol';
import './ActivistContract.sol';
import './CategoryContract.sol';

contract SintropContract is ProducerContract, ActivistContract, CategoryContract {
    enum InspectionStatus { OPEN, CLOSED, CLOSED_WITH_SUCCESS, ACCEPTED }
    
    struct Inspection {
        uint id;
        InspectionStatus status;
        address producer_wallet;
        address activist_wallet;
        uint created_at;
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
        
        Inspection memory inspection = Inspection(id, InspectionStatus.OPEN, msg.sender, msg.sender, block.timestamp);
        inspectionsArray.push(inspection);
        inspections[id] = inspection;
        inspectionsCount++;
    }  
    
    /**
   * @dev Allows the current user (activist) accept a inspection.
   * @param id The id of the inspection that the activist want accept.
   */
    function acceptInspection(uint id) public returns(bool) {
        require(activistExists(msg.sender), "You must be an activist! Please register as one");
        require(inspectionExists(id), "This inspection don't exists");
        
        Inspection memory inspection = inspections[id];
        
        inspection.status = InspectionStatus.ACCEPTED;
        inspection.activist_wallet = msg.sender;
        inspections[id] = inspection;
        
        return true;
    }  
    
    function calculateIsa() public {
        //atribui um nota para cada nível de sustentabilidade
        //faz a média utilizando as categorias mais votadas
        //retorna o ISA
    }
    
    function realizeInspection() public {
        //lista as categorias mais votadas do ISA
        //permite o ativista selecionar um nível por categorias
        //retorna o ISA da inspeção
        
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
        return ("OPEN", "CLOSED", "CLOSED_WITH_SUCCESS", "ACCEPTED");
    }
    
    /**
   * @dev Check if an inspections exists in mapping.
   * @param id The id of the inspection that the activist want accept.
   */
    function inspectionExists(uint256 id) public view returns(bool) {
        bool exists = inspections[id].id >= 1;
        return exists;
    }
    
}
