//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

contract Quiz{
    //creator of quiz game
    address public manager;

    //participants of quiz game
    struct Participant{
        address payable Id;
        uint8 qnaIndex;
        uint8 points;
    }
    mapping(address => Participant) internal participants;
  

    //Questions and Answers Bank
    struct QnA{
        string question;
        int16 answer;
    }
    QnA[] internal qnaBank;

    //keeps track of address who won the quiz in the past
    address[] public quizWinnersHistory;

    //keeps track of the funding given to the contract by the manager
    uint256[] private fundHistory;

    //custom modifiers
    modifier onlyOwner(){
        require(msg.sender == manager,"Only manager can perform this action");
        _;
    }
    modifier onlyParticipants(){
        require(checkEligibility(payable(msg.sender)) == true,"You do not have the ticket to participate in the quiz");
        _;
    }

    //Functions starts from here
    constructor(){
        manager = msg.sender;
        qnaBank.push(QnA({question:"121 Divided by 11 is __",answer:11}));
        qnaBank.push(QnA({question:"What is the Next Prime Number after 7?",answer:11}));
        qnaBank.push(QnA({question:"How Many Years are there in a Decade?",answer:10}));
        qnaBank.push(QnA({question:"How Many Months Make a Century?",answer:1200}));
        qnaBank.push(QnA({question:"How Many Sides are there in a Decagon?",answer:10}));
        qnaBank.push(QnA({question:"What is the perfect cube of 27? ",answer:3}));
        qnaBank.push(QnA({question:"Solve 3 + 6 * ( 5 / 4) / 3 - 7",answer:14}));
        qnaBank.push(QnA({question:"Solve 23 + 3 / 3",answer:24}));
        qnaBank.push(QnA({question:"If 1=3,2=3,3=5,4=4,5=4 Then, 6=?",answer:3}));
        qnaBank.push(QnA({question:"Which number is equivalent to 3^(4)/3^(2)",answer:9}));
    }

    //function for participants to buy quiz ticket
    receive() external payable {
        require(msg.value == 10000 wei,"Please pay the required price to participate");
        participants[msg.sender] = (Participant({Id: payable(msg.sender),qnaIndex: 0,points: 0}));
    }

    //function for the manager to check contract balance
    function contractBal() public view onlyOwner returns(uint256){
        return address(this).balance;
    }

    //function for the manager to fund the contract
    function fundContract() public payable onlyOwner returns(string memory){
        fundHistory.push(msg.value);
        return "Funding Successful";
    }

    //function for the manager to check funding history of the contract
    function fundingHistory(uint256 index) public view onlyOwner returns(uint256){
        return fundHistory[index];
    }

    //function to check if the caller is eligible to play the quiz or not
    function checkEligibility(address payable caller) internal view returns(bool){
        if(caller == participants[caller].Id){
            return true;
        }
        return false;
    }

    //function to reward the player who scores required score
    function reward(address payable caller) internal returns(string memory){
        //if the participant wins, reward them, add them to winners history and delete their entry
        if(participants[caller].points == 10){
            caller.transfer(1000000 gwei);
            quizWinnersHistory.push(caller);
            delete(participants[caller]);
            string memory greet = "Congratulations you have won 0.001 ether";
            return greet;
        }
        //if the participant loses, delete their entry
        delete(participants[caller]);
        string memory console = "Better Luck Next Time";
        return console;
    }

    //function that throws the quiz questions
    function quizMe() public view onlyParticipants returns(string memory _question){
        require(participants[msg.sender].qnaIndex < 10,"You have completed the quiz");
        uint8 index = participants[msg.sender].qnaIndex;
        return qnaBank[index].question;
    }

    //function to submit the quiz answers and check for their correctness
    function submitAnswer(int16 _answer) public onlyParticipants{
        if(participants[msg.sender].qnaIndex < 10){
            uint8 index = participants[msg.sender].qnaIndex;
            if(_answer == qnaBank[index].answer){
                participants[msg.sender].points++;
            }
            participants[msg.sender].qnaIndex++;

            if(participants[msg.sender].qnaIndex >= 10){
                reward(payable(msg.sender));
            }
        }
    }

    //function to view current points earned
    function viewScore() public view returns(uint8){
        return participants[msg.sender].points;
    }

}