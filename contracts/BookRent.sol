//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.0;

// a simple contract for renting books
// there's limited number of books that can be rent in a day
// the qty of books will be fully restored every midnight --> for now it is manually reset
// the price to rent a book is 1 ether --> currently if msg.value is more than 1 ether, the excess value will be sent back first
// make sure whether the sender has rent a book that day, otherwise they can't rent a book

contract BookRent{

    address payable public owner;
    uint initStock;
    uint bookStock;
    uint fee = 1 ether;
    address[] renter;

    constructor(){
        owner = msg.sender;
        initStock = 3;
        bookStock = initStock;
        renter = new address[](bookStock);
    }

    // check if book is still available
    modifier checkAvailability {
        require (bookStock > 0 , "There's no book left. Please return tomorrow.");
        _;
    }

    // check if sender has sufficient balance
    modifier checkBalance {
        require (msg.value >= fee, "Sorry, you don't have sufficient fund.");
        _;
    }

    // check if sender is not owner, and also to transfer back the excess values
    modifier checkSender {
        require (msg.sender != owner, "You can't rent books here");
        if(msg.value > fee){
            msg.sender.transfer(msg.value - fee);
        }
        _;
    }

    // check if sender has rent a book for today
    modifier checkHasRent{
        bool hasRent = false;
        uint i = 0;
        while(hasRent == false && i < initStock - bookStock){
            if(renter[i] == msg.sender){
                hasRent = true;
            }
            i++;
        }
        require (hasRent == false, "You have rent a book for today. Please come again tomorrow");
        _;
    }
    
    // rent transaction; transfer the fee to owner, reduct qty of books available, and add sender address to renter[]
    function rentAbook() payable external checkAvailability checkBalance checkSender checkHasRent{
        bookStock --;
        owner.transfer(fee);
        renter[initStock - 1 - bookStock] = msg.sender;
    }

    // reset book stock
    function resetStock() external { 
        require (msg.sender == owner, "You are not authorized to do this call");
        bookStock = initStock;
        renter = new address[](bookStock);
    }



}