//SPDX-License-Identifier:GPL-3.0
pragma solidity >=0.7.0;
//voting  with delegation 

contract Ballot{

    struct Voter{
        uint weight;
        bool voted;
        address delegate;
        uint vote;

    }
    struct Proposal{
        bytes32 name;
        uint voteCount;

    }
    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    //creating a new ballot

    constructor(bytes32[] memory proposalNames){
        chairperson = msg.sender;
        voters[chairperson].weight =1;

        //create new proposal object for each proposal name
        for(uint i = 0; i < proposalNames.length; i++){
            proposals.push(Proposal({
                name:proposalNames[i],
                voteCount:0
            }));
        }
    }
    //give right to vote
    function giveRightToVote(address voter) external{
        require(
            msg.sender == chairperson,
            "Only chairperson is allowed to give right to vote"

        );

        require(
            !voters[voter].voted,
            "The Voter has aready voted."

        );
        require(voters[voter].weight ==0);
        voters[voter].weight =1;
            

    }

    //delegate your vote to voter `to`
    function delegate(address to) external {
        //assign reference
        Voter storage sender =voters[msg.sender];
        require (!sender.voted, "You already voted.");

        require(to != msg.sender, "self-delegation is not allowed");


        while (voters[to].delegate != address(0)){
            to = voters[to].delegate;
            //loop in the delegation
            require (
                to != msg.sender, "Found loop in delegation");
        }
        //since `sender` is a reference, we modify the `Voters[msg.sender].voted`
        sender.voted =true;
        sender.delegate =to;
        Voter storage delegate_ =voters[to];
        if (delegate_.voted){
            //add vote id delegate has voted
            proposals[delegate_.vote] .voteCount += sender.weight;


        }else{
        //else if delegate hasnt voted, add to her weight
        delegate_.weight += sender.weight;
        }

    }



//to give your vote inclugind those deegated to you
//to proposal `proposal[propoasl].name`.

    function vote(uint proposal) external {
        Voter storage sender =voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "already voted");
        sender.voted =true;
        sender.vote =proposal;

        //if proposal is out of the range of the array,
        //this will throw automatically and revert all changes.

        proposals[proposal].voteCount += sender.weight;
    }

        ///compute the winning proposal taking all votes into account

    function winningProposal() public view
        returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p =0; p <proposals.length; p++){
            if (proposals[p].voteCount>winningVoteCount){
                winningVoteCount = proposals[p].voteCount;
                winningProposal_=p;
            }
        }
    }


    function winnerName() external view
    returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }


}