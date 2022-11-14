//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Lottery{
    //the manager is of address type, which will store the address of the person who deployed the contract
    //manager has the privilege to check contract balance and start the lottery round
    address public manager;

    //address of the participants in the lottery will be stored in this array
    //it is payable because one of the participants from the array, when declared winner, will recieve ether 
    address payable[] public participants;

    //this constructor will be called when the contract is first deployed 
    //and the address of the account that deployed the contract will be stored in manager
    constructor(){
        manager = msg.sender;  //msg.sender stores the address of the account that called the function
                              //Here, constructor is automatically called when contract is deployed, 
                              //so msg.sender will store address that deployed the contract
    }

    //recieve function is used to recieve ether from participants
    //use case of recieve() can be searched on the net
    receive() external payable{
        //require is similar to if-else, when the condition inside require is met the lines after gets executed 
        require(msg.value == 8100000000000000 wei); //0.0081 ether

        //if valid amount of ether is recieved, then the sender's address is stored in participants[]
        //Here, recieve() is automatically called when transact is used, so msg.sender will store address,
        //that did the transact
        participants.push(payable(msg.sender));  //explicity converting participant's address to payable
    }

    //check balance
    function getBalance() public view returns(uint256){
        //condition which allows only the manager to check balance
        require(msg.sender == manager);

        //'this' keyword points to current contract
        //address(this) gives the address 'this' is pointing towards
        //.balance is inbuilt functionality to fetch balance
        return address(this).balance;
    }

    //to generate a random number
    function randomNumberGenerator() private view returns(uint256){
        //using inbuilt keccak256 hashing algorithm to generate a 256 bit hash
        //type conversion from 256 bits hexadecimal hash value to uint256
        //Note: Do not use this code/logic to generate random number in real projects,
        //as it may sometimes generate same number, this is just for a test project 
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    }

    //winner selection
    function selectWinner() public{
        //only manager can call this function
        require(msg.sender == manager);

        //Number of participants must be more than 2, in order to select a winner
        require(participants.length > 2);

        //fetching a random number
        uint256 randomNumber = randomNumberGenerator();

        //modulo operation on 64 digit number to acquire random array index within valid range
        uint256 index = randomNumber % participants.length;

        //address at that index is selected as a winner
        address payable winner = participants[index];

        //transfer ether from this contract to the winner
        winner.transfer(getBalance());
        
        //reset the participant list for next round
        participants = new address payable[](0);
    }

}