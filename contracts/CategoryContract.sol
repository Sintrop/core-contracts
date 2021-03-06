// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

import "./PoolPassiveInterface.sol";
import "./types/CategoryTypes.sol";

/**
 * @author Sintrop
 * @title CategoryContract
 * @dev Category resource that is a part of Sintrop business
 */
contract CategoryContract {
  mapping(uint256 => Category) public categories;
  mapping(uint256 => uint256) public votes;
  mapping(address => mapping(uint256 => uint256)) public voted;

  Category public category;
  uint256 public categoryCounts;
  PoolPassiveInterface internal isaPool;

  constructor(address _isaPoolAddress) {
    isaPool = PoolPassiveInterface(_isaPoolAddress);
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

    for (uint256 i = 0; i < categoryCounts; i++) {
      categoriesList[i] = categories[i + 1];
    }

    return categoriesList;
  }

  /**
   * @dev Allow a user vote in a category sending tokens amount to this
   * @param id the id of a category that receives a vote.
   * @param tokens the tokens amount that the use want use to vote.
   * @return boolean
   */
  function vote(uint256 id, uint256 tokens)
    public
    categoryMustExists(id)
    mustHaveSacToken(tokens)
    mustSendSomeSacToken(tokens)
    returns (bool)
  {
    isaPool.transferWith(msg.sender, tokens);

    votes[id] += tokens;
    voted[msg.sender][id] += tokens;

    categories[id].votesCount++;
    return true;
  }

  /**
   * @dev Allow a user unvote in a category and get your tokens again
   * @param id the id of a category that receives a vote.
   * @return uint256
   */
  function unvote(uint256 id) public categoryMustExists(id) mustHaveVoted(id) returns (uint256) {
    uint256 tokens = voted[msg.sender][id];

    isaPool.approveWith(msg.sender, tokens);

    votes[id] -= tokens;
    voted[msg.sender][id] = 0;
    categories[id].votesCount--;

    return tokens;
  }

  // MODIFIERS

  modifier categoryMustExists(uint256 id) {
    require(categories[id].id > 0, "This category don't exists");
    _;
  }

  modifier mustHaveSacToken(uint256 tokens) {
    require(isaPool.balanceOf(msg.sender) > tokens, "You don't have tokens to vote");
    _;
  }

  modifier mustSendSomeSacToken(uint256 tokens) {
    require(tokens > 0, "Send at least 1 SAC Token");
    _;
  }

  modifier mustHaveVoted(uint256 id) {
    require(voted[msg.sender][id] > 0, "You don't voted to this category");
    _;
  }
}
