// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {

    //Owner
    address owner;

    uint256 private counter;

    struct Proposal {
        string description;
        uint256 approve; 
        uint256 reject; 
        uint256 pass; 
        uint256 total_vote_to_end; 
        bool current_state;
        bool is_active;
    }

    mapping(uint256 => Proposal) proposal_history;

    address[] private voted_addresses; 

    //constructor
    constructor() {
        owner = msg.sender;
        voted_addresses.push(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier active() {
        require(proposal_history[counter].is_active == true);
        _;
    }

    modifier newVoter(address _address) {
        require(!isVoted(_address), "Address has not voted yet");
        _;
    }


    function setOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }

    function create(string calldata _description, uint256 _total_vote_to_end) external onlyOwner {
        counter += 1;
        proposal_history[counter] = Proposal(_description, 0, 0, 0, _total_vote_to_end, false, true);
    }
    

    function vote(uint8 choice) external active newVoter(msg.sender){
        Proposal storage proposal = proposal_history[counter];
        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;

        voted_addresses.push(msg.sender);

        if (choice == 1) {
            proposal.approve += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 2) {
            proposal.reject += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 0) {
            proposal.pass += 1;
            proposal.current_state = calculateCurrentState();
        }

        if ((proposal.total_vote_to_end - total_vote == 1) && (choice == 1 || choice == 2 || choice == 0)) {
            proposal.is_active = false;
            voted_addresses = [owner];
        }
    }

    function terminateProposal() external onlyOwner active {
        proposal_history[counter].is_active = false;
    }


    function calculateCurrentState() private view returns(bool) {
        Proposal storage proposal = proposal_history[counter];

        uint256 totalVotes = proposal.approve + proposal.reject + proposal.pass;
    
        // If the total number of votes is odd, add one to pass
        uint256 pass = (totalVotes % 2 == 1) ? (proposal.pass + 1) / 2 : proposal.pass / 2;

     return proposal.approve > proposal.reject + pass;
    }



    function isVoted(address _address) public view returns (bool) {
        for (uint i = 0; i < voted_addresses.length; i++) {
            if (voted_addresses[i] == _address) {
                return true;
            }
        }
        return false;
    }


    function getCurrentProposal() external view returns(Proposal memory) {
        return proposal_history[counter];
    }

    function getProposal(uint256 number) external view returns(Proposal memory) {
        return proposal_history[number];
    }
}