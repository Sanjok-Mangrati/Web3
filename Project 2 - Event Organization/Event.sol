//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract EventContract{

    //event details stored in a structure
    struct Event{
        address organizer;
        string name;
        string venue;
        uint date;
        uint ticketPrice;
        uint totalTickets;
        uint ticketsSold;
        uint ticketsLeft;
    }

    //allows creation of multiple Events and provides access to particular Event corresponding to provided Event Id
    mapping(string=>Event) public events;

    //To record which address owns tickets of which events and the quanity
    //           |---> [ event 1 ]-----> quantity     |
    //  address1 | --> [ event 2 ]-----> quantity     |   address2 | --> [ event 3 ]-----> quantity
    //           |---> [ event 3 ]-----> quantity     |
    mapping(address=>mapping(string=>uint)) public ticketLog;


    function createEvent(string memory eventId, string memory _name, string memory _venue, uint _date, uint _ticketPrice, uint _totalTickets) public {
        
        //creation of event and pairing it with the given eventId/key
        //anyone who create's the event will be set as organizer
        events[eventId] = Event(msg.sender,_name,_venue,_date,_ticketPrice,_totalTickets,0,_totalTickets);
    }

    function buyTicket(string memory eventId, uint quantity) public payable{
        require(events[eventId].date != 0, "Exception: Event does not exist");
        require(events[eventId].date > block.timestamp, "Exception: Event has already occured");
        require(quantity <= events[eventId].ticketsLeft, "Exception: Cannot fulfill the quantity");
        require(msg.value == events[eventId].ticketPrice * quantity, "Exception: Required amount not paid");

        ticketLog[msg.sender][eventId] += quantity; //mapping [address] --->{ [event] ---> [quantity] } 
        events[eventId].ticketsSold += quantity;
        events[eventId].ticketsLeft -= quantity;
    }

    function transferTicket(string memory eventId, uint quantity, address recipient) public {
        require(events[eventId].date != 0, "Exception: Event does not exist");
        require(events[eventId].date > block.timestamp, "Exception: Event has already occured");
        require(quantity <= ticketLog[msg.sender][eventId], "Exception: You do not have the required quantity");

        ticketLog[msg.sender][eventId] -= quantity;  //decrement ticket quantity from sender
        ticketLog[recipient][eventId] += quantity;  ////increment ticket quantity of reciever
    }
}