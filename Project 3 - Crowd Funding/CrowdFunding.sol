//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract CrowdFunding{
    address payable public manager;
    mapping(address=>uint) public contributors;   //mapping address of contributor with their contribution amount
    uint256 public targetFund;
    uint256 public deadline;
    uint256 public minimumContribution;
    uint256 public fundRaised;
    uint256 public contributorCount;

    //setting target value, deadline and minimum contribution value at the time of deployment
    constructor(uint256 target, uint256 _deadline, uint256 minContribution){
        manager = payable(msg.sender);
        targetFund = target;
        deadline = block.timestamp + _deadline;  //adding no of seconds before the deadline to current block time
        minimumContribution = minContribution;
    }

    function sendEth() public payable {
        require(block.timestamp < deadline,"Exception: Fundraising deadline has expired");
        require(msg.value >= minimumContribution,"Exception: Minimum Contribution Amount not met");
        
        //checking if the address has contributed before or not, if yes do not increase number of contributors
        if(contributors[msg.sender] == 0){
            contributorCount++;
        }
        contributors[msg.sender] += msg.value;
        fundRaised += msg.value;
    }

    function refund() public {
        require(block.timestamp > deadline && fundRaised < targetFund,"Exception: You are not eligible for a refund");
        require(contributors[msg.sender] > 0,"Exception: You have not contributed in this fund");

        payable(msg.sender).transfer(contributors[msg.sender]);  //transfer msg.sender's contribution amount back
        contributors[msg.sender] = 0;  //after refund set the address contribution back to 0
        fundRaised -= contributors[msg.sender];
        contributorCount--;
    }

    //structure using which the manager can request to use fund from the contract
    struct Request{
        string cause;
        uint256 amount;
        address payable recipient;
        bool isFunded;
        uint256 voterCount;
        mapping(address=>bool) voters; //by default uinitialized bool value is false
    }
    mapping(uint256=>Request) public requests;  //to organize requests in order ---->  array can be used instead of mapping
    uint256 requestId;  //acts as a index for the requests mapping ---------------|

    //custom modifier
    modifier onlyManager{
        require(msg.sender == manager,"Exception: Only manager can perform this action");
        _;
    }

    function createRequest(string memory _cause, uint256 _amount, address payable _recipient) public onlyManager{
        Request storage newRequest = requests[requestId];  //storage because the structure contains mapping inside it, and mapping are always stored in storage
        newRequest.cause = _cause;
        newRequest.amount = _amount;
        newRequest.recipient = _recipient;
        newRequest.isFunded = false;
        newRequest.voterCount = 0;
        newRequest.voters[msg.sender] = false;
        requestId++;
    }

    function vote(uint256 id) public {
        Request storage currentRequest = requests[id];
        require(contributors[msg.sender] > 0,"Exception: Only contributors can vote");
        require(id >= 0 && id <= requestId,"Exception: You cannot vote for a request that does not exist");
        require(currentRequest.voters[msg.sender] == false,"Exception: You have already voted for this request");

        currentRequest.voters[msg.sender] = true; //set the address state to voted
        currentRequest.voterCount++;
    }

    function fundtheCause(uint256 id) public onlyManager {
        require(fundRaised >= targetFund && fundRaised >= requests[id].amount,"Exception: Not enough fund to fulfill request");
        require(requests[id].isFunded == false,"This request has already been funded");
        require(requests[id].voterCount > contributorCount/2,"Majority does not support funding this cause");
        Request storage currentRequest = requests[id];
        currentRequest.recipient.transfer(currentRequest.amount);
        currentRequest.isFunded = true;
    }
}