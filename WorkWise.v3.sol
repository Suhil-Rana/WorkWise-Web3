// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Project {
    address public client;
    address public freelancer;
    uint public milestoneAmount;
    uint public totalAmount;
    uint public releasedAmount;
    bool public jobActive = true;

    event JobCreated(address indexed client, uint totalAmount);
    event FreelancerAssigned(address indexed freelancer);
    event MilestoneApproved(uint amount);
    event JobCompleted();
    event PaymentReleased(address indexed to, uint amount);

    constructor() {
        // Set default values here
        client = msg.sender;

        totalAmount = 1 ether;        // Default: 1 ETH (set as needed)
        milestoneAmount = 0.2 ether;  // Default: 0.2 ETH per milestone (set as needed)
        emit JobCreated(client, totalAmount);
    }
    
    // Fund contract after deployment
    function fund() external payable {
        require(msg.sender == client, "Only client can fund");
        require(address(this).balance + releasedAmount <= totalAmount, "Cannot overfund");
    }

    function assignFreelancer(address _freelancer) public {
        require(msg.sender == client, "Only client can assign");
        require(freelancer == address(0), "Freelancer already assigned");
        freelancer = _freelancer;
        emit FreelancerAssigned(freelancer);
    }

    function approveMilestone() public {
        require(msg.sender == client, "Only client can approve");
        require(jobActive, "Job is not active");
        require(releasedAmount + milestoneAmount <= totalAmount, "Exceeds total");
        require(address(this).balance >= milestoneAmount, "Insufficient contract balance");
        releasedAmount += milestoneAmount;
        payable(freelancer).transfer(milestoneAmount);
        emit MilestoneApproved(milestoneAmount);
        emit PaymentReleased(freelancer, milestoneAmount);

        if (releasedAmount == totalAmount) {
            jobActive = false;
            emit JobCompleted();
        }
    }
}
