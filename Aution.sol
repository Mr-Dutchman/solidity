//SPDX-License-Identifier:GPL-3.0
pragma solidity >= 0.7.0;
//blind auction

contract BlindAuction{
    struct Bid {
        bytes32 blindedBid;
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

    //errors that describes failures

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
        if (block.timestamp <= time) revert TooEarly(time);
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
    /// Place a blinded bid with `blindedBid` =
    /// keccak256(abi.encodePacked(value, fake, secret)).
    /// The sent ether is only refunded if the bid is correctly
    /// revealed in the revealing phase. The bid is valid if the
    /// ether sent together with the bid is at least "value" and
    /// "fake" is not true. Setting "fake" to true and sending
    /// not the exact amount are ways to hide the real bid but
    /// still make the required deposit. The same address can
    /// place multiple bids.  

    function bid(bytes32 blindedBid)
    external payable onlyBefore(biddingEnd)
    {
        bids[msg.sender].push(Bid({
            blindedBid:blindedBid,
            deposit:msg.value
        }));
    }  


    //reavel your blinded bids. you will get a refund for all correctly blinded invalids bids and for all bids excep for the totally highest.

    function reveal(
        uint[] calldata values,
        bool[] calldata fakes,
        bytes32[] calldata secrets
    )
        external 
        onlyAfter(biddingEnd)
        onlyBefore(revealEnd)
        {
            uint length = bids[msg.sender].length;
            require(values.length == length);
            require(fakes.length == length);
            require(secrets.length ==length);

            uint refund;
            for (uint i =0; i <length; i++){
                Bid storage bidToCheck = bids[msg.sender][i];
                (uint value, bool fake, bytes32 secret) =
                (values[i], fakes[i], secrets[i]);

                if( bidToCheck.blindedBid != keccak256(abi.encodePacked(value, fake, secret))){
                    //bid was not actuall revealed
                    //do not return deposit
                    continue;

                }
                refund += bidToCheck.deposit;
                if(!fake && bidToCheck.deposit>= value){
                    if(placeBid(msg.sender,value))
                        refund-=value;
                }
                //makes it impossible for sender to reclaim the same deposit
                bidToCheck.blindedBid = bytes32(0);

            }
            payable(msg.sender).transfer(refund);
        }

        ///withdraw a bid that was over bid
        function withdraw() external{
            uint amount =pendingReturns[msg.sender];
            if (amount>0){
                // It is important to set this to zero because the recipient
                // can call this function again as part of the receiving call
                // before `transfer` returns (see the remark above about
                // conditions -> effects -> interaction).
                pendingReturns[msg.sender] =0 ;

                payable(msg.sender).transfer(amount);
            

            }

        }
        function AuctionEnd() external onlyAfter(revealEnd){
            if (ended) revert AuctionEndAlreadyCalled();
            emit AuctionEnded(highestBidder, highestBid);
            ended = true;
            beneficiary. transfer(highestBid);

        }

        /**
        this is an internal function which means that it can only be called
        from the contract itself(or from derived contract) 
        */

        function placeBid(address bidder, uint value) internal
        returns (bool success){
            if (value <= highestBid){
                return false;

            }

            if (highestBidder != address(0)) {
                //refund the previously highest bidder.
                pendingReturns[highestBidder] += highestBid;


            }
            highestBid =value;
            highestBidder =bidder;
            return true;
        }
    
}