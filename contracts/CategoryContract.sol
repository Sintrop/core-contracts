// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


   /**
    * @title CategoryContract
   * @dev Category resource that is a part of Sintrop business
   */
   contract CategoryContract {
    enum isas { TOTALLY_SUSTAINABLE, PARTIAL_SUSTAINABLE, NEUTRO, PARTIAL_NOT_SUSTAINABLE, TOTALLY_NOT_SUSTAINABLE }
       
    struct Category {
        uint256 id;
        address createdBy;
        string name;
        string description;
        string totallySustainable;
        string partiallySustainable;
        string neutro;
        string partiallyNotSustainable;
        string totallyNotSustainable;
        uint votesCount;
        uint index;
    }
    Category public category;
    uint public categoryCounts;
    Category[] categoriesArray;
    mapping(uint => Category) categories;

    
    /**
   * @dev Returns all added categories
   * @return category struc array
   */
    function getCategories() public view returns(Category[] memory) {
        return categoriesArray;
    }
    
    /**
   * @dev add a new category
   * @param name the name of category
   * @param description the description of category
   * @param totallySustainable the description text to this metric
   * @param partiallySustainable the description text to this metric
   * @param neutro the description text to this metric
   * @param partiallyNotSustainable the description text to this metric
   * @param totallyNotSustainable the description text to this metric
   * @return bool
   */
    function addCategory(
        string memory name, 
        string memory description, 
        string memory totallySustainable, 
        string memory partiallySustainable, 
        string memory neutro, 
        string memory partiallyNotSustainable, 
        string memory totallyNotSustainable) public returns(bool) {
        uint256 id = categoryCounts + 1;
        uint index = id - 1;
        
        category = Category(id, msg.sender, name, description, totallySustainable, partiallySustainable, neutro, partiallyNotSustainable, totallyNotSustainable, 0, index);
        
        categoriesArray.push(category);
        categories[id] = category;
        categoryCounts++;
        
        return true;
    }
    
    /**
   * @dev Allow a user vote in a category
   * @param id the id of a category that receives a vote.
   * @return category struc array
   */
    function vote(uint id) categoryMustExists(id) public returns (bool) {
        Category memory categoryVoted = categories[id];
        categories[id].votesCount++;
        categoriesArray[categoryVoted.index].votesCount++;
        
        return true;
    }
    
    /**
   * @dev get a specific category
   * @param id the id of a category
   */
    function getCategory(uint id) public view returns(Category memory) {
        return categories[id];
    }
    
    /**
   * @dev Returns all isas string.
   */
    function getIsas() public pure returns(string memory, string memory, string memory, string memory, string memory) {
        return ("TOTALLY_SUSTAINABLE", "PARTIAL_SUSTAINABLE", "NEUTRO", "PARTIAL_NOT_SUSTAINABLE", "TOTALLY_NOT_SUSTAINABLE");
    }
    
    // Modifiers
    modifier categoryMustExists(uint id) {
        require(uint(id) == id, "The id of category must be passed");
        require(categories[id].id > 0, "This category don't exists");
        
        _;
    }
}