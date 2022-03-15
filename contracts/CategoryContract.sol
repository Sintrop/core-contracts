// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

/**
 * @title CategoryContract
 * @dev Category resource that is a part of Sintrop business
 */
contract CategoryContract {
    enum isas {
        TOTALLY_SUSTAINABLE,
        PARTIAL_SUSTAINABLE,
        NEUTRO,
        PARTIAL_NOT_SUSTAINABLE,
        TOTALLY_NOT_SUSTAINABLE
    }

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
        uint256 votesCount;
    }
    Category public category;
    uint256 public categoryCounts;
    mapping(uint256 => Category) public categories;

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
        string memory totallyNotSustainable
    ) public returns (bool) {
        category = Category(
            categoryCounts + 1,
            msg.sender,
            name,
            description,
            totallySustainable,
            partiallySustainable,
            neutro,
            partiallyNotSustainable,
            totallyNotSustainable,
            0
        );

        categories[category.id] = category;
        categoryCounts++;

        return true;
    }

    /**
     * @dev Returns all added categories
     * @return category struc array
     */
    function getCategories() public view returns (Category[] memory) {
        Category[] memory categoriesList = new Category[](categoryCounts);

        for(uint i = 0; i < categoryCounts; i++){
            categoriesList[i]= categories[i+1];
        }

        return categoriesList;
    }

    /**
     * @dev Allow a user vote in a category
     * @param id the id of a category that receives a vote.
     * @return category struc array
     */
    function vote(uint256 id) public categoryMustExists(id) returns (bool) {
        categories[id].votesCount++;
        return true;
    }

    // Modifiers
    modifier categoryMustExists(uint256 id) {
        require(categories[id].id > 0, "This category don't exists");
        _;
    }
}
