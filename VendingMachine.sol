// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

/*
 * Allows a customer to buy an item from a vending machine.
 * A current inventory count can be read at any time by anyone.
 * The customer pays the specified fee for an item and the available inventory is adjusted after releasing the item to the customer.
 * The machine can hold up to 3 items and 10 of each item.
 * The owner can collect the funds at any time.
 */

import "./StringUtils.sol"; //library providing functions for comparing strings

contract VendingMachine {
    //state variables
    address payable private owner;
    Item[3] Machine; //holds 3 items

    //contract constructor
    constructor () {
        owner = payable(msg.sender);
    }

    //item struct
    struct Item {
        string name;
        uint256 price;
        uint8 inventoryCount;
    }

    //contract settings
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this.");
        _;
    }

    //withdraw all funds
    function withdrawFunds() public onlyOwner {
        require(address(this).balance > 0, "There is nothing to collect");
        owner.transfer(address(this).balance);
    }

    //check inventory of the selected item
    function checkItemInventory(string memory itemName) public view returns(uint8) {
        for(uint8 i = 0; i < Machine.length; i++) {
            //if the item is found, set the inventory count to 10
            if(StringUtils.equal(itemName, Machine[i].name)) {
                return Machine[i].inventoryCount;
            }
        }

        //returns 100 if the item is not found
        return 100;
    }

    //stock Inventory
    function stockInventory(Item memory item0, Item memory item1, Item memory item2) public onlyOwner {
        //assign the machine array with the items
        Machine[0] = item0;
        Machine[1] = item1;
        Machine[2] = item2;
    }

    //restock inventory
    function restockInventory(string memory itemName, uint8 itemCount) public onlyOwner {
        //loop through array of items searching for a matching item name
        for(uint8 i = 0; i < Machine.length; i++) {
            //if the item is found, set the inventory count to 10
            if(StringUtils.equal(itemName, Machine[i].name)) {
                //add to the current inventory count of the item, then break the search loop
                Machine[i].inventoryCount += itemCount;
                break;
            }
        }
    }

    //get and item's info
    function getItem(string memory itemName) private view returns(Item memory) {
        //loop through Machine array and find item with specified name
        for(uint8 i = 0; i < Machine.length; i++) {
            if(StringUtils.equal(itemName, Machine[i].name)) {
                return Machine[i];
            }
        }

        //return a blank item if the requested item is not found
        return Item("NONE", 0, 0);
    }

    //purchase item
    function purchaseItem(string memory itemName) public payable {
        //select item by name
        Item memory chosenItem = getItem(itemName);

        //verify the item exists
        if(StringUtils.equal(chosenItem.name, "NONE")) {
            //revert transaction if the item does not exist
            revert("Item does not exist");
        }

        //verify the item is in stock and the sender's funds match or exceed the item's price
        require(chosenItem.inventoryCount > 0 && chosenItem.inventoryCount != 100, "Out of stock");
        require(msg.value == chosenItem.price, "Not enough or too much money was sent");

        //subtract inventory count by 1
        for(uint8 i = 0; i < Machine.length; i++) {
            if(StringUtils.equal(chosenItem.name, Machine[i].name)) {
                Machine[i].inventoryCount -= 1;
            }
        }
    }
}
