pragma solidity ^0.8.0;
// SPDX-License-Identifier: GPL-3.0-or-later

contract sintropAgriculture {
    
    mapping(uint => Producer) public producers;
    mapping (uint => address) public producerToOwner;
    mapping(uint => Activist) public activists;
    mapping (uint => address) public activistToOwner;
    
    constructor() {
        
    }
    
    struct Producer{
        string name;
        string location;
        string description;
        //uint256 isa;
    }
    
    struct Activist{
        string name;
        string location;
        string description;
        
    }
    
    /* struct IndexSustainableAgriculture {
        uint256 slo1;
        uint256 slot2;
        uint256 slot3;
    } */

    
    event NewProducer(uint _id, string _location, string _description);
    event NewActivist(uint _id, string _location, string _description);
    event InspectionCompleted(uint isa, uint biodiversity, uint soilQuality);
    event inspectionRequested ();


    function addProducer(uint _id, string memory _name, string memory _location, string memory _description) public {
        // require endereço válido
        producers[_id] = Producer(_name, _location, _description);
        producerToOwner[_id] = msg.sender;
        emit NewProducer(_id, _location, _description);
    }
    
    function addActivist(uint _id, string memory _name, string memory _location, string memory _description) public {
        // require endereço válido
        // adiciona nome, descrição e localização.
        activists[_id] = Activist(_name, _location, _description);
        // atribui informações ao msg.sender
        activistToOwner[_id] = msg.sender;
        // emite evento de novo produtor
        emit NewActivist(_id, _location, _description);
        
    }
    
    function requestInspection () public {
        // requisção: produtor precisa estar registrado
        //require(bytes(_name).length > 0);
        // calcula fee a ser paga 
        // autoriza a transação
        // emite evento de inspeção requisitada
        
    }
    
    function inspectProducer (uint256 slot1, uint256 slot2, uint256 slot3) public returns (uint256){
        // requer que seja um ativista validado
        // atribui nota aos indicadores
        // realiza a trnasferência do produtor para o ativista
        // registra as informações do ativista no ISA do produtor
        // emite evento de inspeção completa
        // gera ISA do produtor
        // exibe se o produtor foi aprovado ou não
        // aumenta a quantidade de inspeções do produtor
        // aumenta a quantidade de inspeções do ativista
       
    }
    
    function calculateIsa (uint256 deforestation, uint256 soilQuality, uint256 chemicals) private {
        // requer evento de inspeção completa
        // faz a conta do ISA
        // retorna isa 
        
    }
    
    function approveProducer () private {
        // requer produtor cadastrado
        // requer isa > x 
        // retorna bool
        
    }
    
    function addToMinting () public {
        // requer produtor aprovado 
        // autoriza produtor chamar função
        // adiciona produtor na mineração
    }
    
}

    
    
    struct slots {
        string title;
        string totallySustainable;
        string mostlySustainable;
        string neutro;
        string mostlyNotSustainable;
        string totallyNotSustainable;
    }
    
    function addCategorieSlot () public {
        
    }
    
    
}
