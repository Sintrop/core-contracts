pragma solidity >=0.5.0 <=0.9.0;
// SPDX-License-Identifier: GPL-3.0-or-later


contract inspectionContract {
    enum InspectionStatus { OPEN, CLOSED, CLOSED_WITH_SUCCESS, ACCEPTED }
    
    struct Inspection {
        uint id;
        InspectionStatus status;
        address producer_wallet;
        uint created_at;
    }
    
    Inspection[] inspections;
    uint inspectionsCount;

    function requestInspection() public {
        uint id = inspectionsCount + 1;
        
        Inspection memory inspection = Inspection(id, InspectionStatus.OPEN, msg.sender, block.timestamp);
        inspections.push(inspection);
        inspectionsCount++;
    }  
    
    function acceptInspection(uint inspection_id) public {
        
        //require ativista validado
        //aceita inspeção
        //permite que o ativista realize a inspeção por um determinado período de tempo (exemplo 1 dia)
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
    
    function getRequestedInspections() public view returns (Inspection[] memory) {
        return inspections;
    }
    
    function getInspectionsStatus() public pure returns(string memory, string memory, string memory, string memory) {
        return ("OPEN", "CLOSED", "CLOSED_WITH_SUCCESS", "ACCEPTED");
    }
    
}