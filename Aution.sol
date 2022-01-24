//SPDX-License-Identifier:GPL-3.0
pragma solidity >= 0.7.0;
//blind auction

contract BlindAuction{
    struct Bid{
        bytes32 blindBid;
        uint deposit;

    }
    address payable public beneficiary;
    uint public biddingEnd;
    uint public revealEnd;
    bool public ended;
    mapping(address =>Bid[]) public bids;
    
    address public highestBidder;
    uint public highestBid;

    //allow withdraw from previous bid
    mapping(address => uint) pendingReturns;
    event AuctionEnded(address winner, uint highest);

    //errors that describ failures

    ///the function has been called too early.
    ///try at later time `time`

    error TooEarly(uint time);

    ///function has been called too late
    ///cannot be called after time `time`

    error TooLate(uint time);

    ///the function auctionEnd has been called
    error AuctionEndAlreadyCalled();

    //validiating functions input
    modifier onlyBefore(uint time){
        if (block.timestamp >= time) revert TooLate(time);
        _;

    }

    modifier onlyAfter(uint time){
        if (block.timestamp <= time) revert TooEarly();
        _;

    }


    constructor(
        uint biddingTime,
        uint revealTime,
        address payable beneficiaryAddress
    ){
        beneficiary = beneficiaryAddress;
        biddingEnd = block.timestamp + biddingTime;
        revealEnd =biddingEnd + revealTime;



    }
    




}