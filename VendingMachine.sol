// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

/*
 * Allows a customer to buy and item from a vending machine.
 * A current inventory count can be read at any time by anyone.
 * The customer pays the specified fee for an item and the available inventory is adjusted after releasing the item to the customer.
 * The machine can hold up to 10 items and 10 of each item.
 * The owner can collect the funds at any time.
 */

import "./StringUtils.sol"; //library providing functions for comparing strings

contract VendingMachine {
    //state variables
    address payable private owner;
    Item[3] private Machine; //holds 10 items

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

    //check inventory of the selected item
    function checkItemInventory(string memory itemName) public view returns(uint8) {
        for(uint8 i = 0; i < Machine.length; i++) {
            //if the item is found, set the inventory count to 10
            if(StringUtils.equal(itemName, Machine[i].name)) {
                return Machine[i].inventoryCount;
            }
        }
        return 100;
    }

    //stock Inventory
    function stockInventory(Item memory item0, Item memory item1, Item memory item2) public onlyOwner {
        //assign the machine array with a complete items array
        //Formated as?: [[itemName, itemPrice, inventoryCount], [...], [...]]
        //loop through Machine and assign values individually from firstInventory
        Machine[0] = item0;
        Machine[1] = item1;
        Machine[2] = item2;

    }

    //restock inventory
    function restockInventory(string memory itemName) public onlyOwner {
        //loop through array of items searching for a matching item name
        for(uint8 i = 0; i < Machine.length; i++) {
            //if the item is found, set the inventory count to 10
            if(StringUtils.equal(itemName, Machine[i].name)) {
                Machine[i].inventoryCount = 10;
            }
        }
    }
}