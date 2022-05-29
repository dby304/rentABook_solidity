//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.0;

// a simple contract for renting e-books
// there are several titles of book that can be rented out. since this is an e-book, no need to return it back
// after rent transaction, the user can access the selected title for a period of time --> for testing purpose, it is now limited for 1 minutes after transaction
// the price to rent a book is 1 ether --> currently if msg.value is more than 1 ether, the excess value will be sent back first


contract BookRent{

    address payable public owner;
    uint fee;
    Renter[] renter;
    BookTitle[] public bookTitles;

    mapping(uint => string) bookTitle;

    struct Renter{
        address person;
        uint bookId;
        uint validUntil;
    }

    struct BookTitle{
        uint bookId;
        string bookTitle;
    }

    constructor(){
        owner = msg.sender;
        fee = 1 ether;
        bookTitles.push(BookTitle(0, "A Study in Scarlet"));
        bookTitles.push(BookTitle(1, "Brokeback Mountain"));
        bookTitles.push(BookTitle(2, "Children of Sokovia"));
        bookTitles.push(BookTitle(3, "Daydreams"));
    }


    // check if sender has sufficient balance
    modifier checkBalance {
        require (msg.value >= fee, "Sorry, you don't have sufficient fund.");
        _;
    }

    // check isOwner
    function checkIsOwner() internal view returns(bool){
        bool isOwner = false;
        if(msg.sender == owner){
            isOwner = true;
        }
        return isOwner;
    }

    // check if sender is not owner, and also to transfer back the excess values
    modifier checkSender {
        require (checkIsOwner() == false, "You can't rent books here");
        if(msg.value > fee){
            msg.sender.transfer(msg.value - fee);
        }
        _;
    }

    // check if renter still has active rent on said book
    function checkStillActive(uint _bookId) internal view returns(bool){
        bool stillActive = false;
        uint i = 0;
        while (stillActive == false && i< renter.length){
            if(renter[i].person == msg.sender && renter[i].bookId == _bookId && renter[i].validUntil > block.timestamp){
                stillActive = true;
            }
            i++;
        }
        return stillActive;
    }

    // rent transaction, check if they already rent said book or whether they input the right book Id
    // if all condition is met, proceed to pay rent fee and record the rent (address, bookId, expired time)
    function rentAbook(uint _bookId) payable external checkBalance checkSender{
        require (checkStillActive(_bookId) == false, "You already have active rent on this book");
        require (_bookId < bookTitles.length, "Wrong book Id");
        owner.transfer(fee);
        renter.push(Renter(msg.sender, _bookId, block.timestamp + 60));
    }

    // read the book after transaction
    function readABook(uint _bookId) external view{
        require (checkStillActive(_bookId) == true, "You don't have active rent on this book");
    }


}