// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract CategoryContract {
    struct Category {
        address createdBy;
        string name;
        string description;
        string totallySustainable;
        string partiallySustainable;
        string neutro;
        string partiallyNotSustainable;
        string totallyNotSustainable;
        int16 votesCount;
    }
    Category category;
    uint public categoryCounts;
    Category[] categories;
    
    function getCategories() public view returns(Category[] memory) {
        return categories;
    }
    
    function addCategory(string memory name, string memory description, string memory totallySustainable, string memory partiallySustainable, string memory neutro, string memory partiallyNotSustainable, string memory totallyNotSustainable) public returns(bool) {
        category = Category(msg.sender, name, description, totallySustainable, partiallySustainable, neutro, partiallyNotSustainable, totallyNotSustainable, 0);
        
        categories.push(category);
        categoryCounts++;
        
        return true;
    }
    
    function getLastCategory() public view returns(Category memory) {
        return category;
    }
    
    function vote(string memory categoryName) public returns (bool) {
        for (uint i = 0; i < categories.length; i++) {
            Category memory categoryVoted = categories[i];
            if (keccak256(bytes(categoryName)) == keccak256(bytes(categoryVoted.name))) {
                categories[i].votesCount++;
                break;
            }
        }
        
        return true;
    }
    
    // modifier requireCategoryname(string memory name) {
    //     require( bytes(name).length > 0);
    //     _;
    // };
    // modifier requireUniqueCampaignName(string memory name) {
    //     bool nameExists = true
    //     require( !nameExists );
    //     _;
    // }
}