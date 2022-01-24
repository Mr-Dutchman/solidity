//SPDX-License-Identifier:GPL-3.0
pragma solidity >= 0.7.0;

//A transparent voting Auction
contract  SimpleAuction{
    //parameter for the auction
    address payable public beneficiary;
    uint public auctionEndTime;

    //current state if the aution.
    address public highestBidder;
    uint public highestBid;

    //allowed withdraw from the previous bid

    mapping(address =>uint) pendingReturns;

    //set to true at the end , disallow any change.
    //by default, initialize to false.
    bool ended;

    //event that will be emmited on changes.
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    
    //Errors that describe failures
    ///The auction has already ended
    error AuctionAlreadyEnded();
    ///There is already a higher or equal bid
    error BidNotHighEhough();
     /// The auction has not ended yet.
    error AuctionNotYetEnded();
    ///the function autionEnd() has already been called.
    error AuctionEndAlreadyCalled();


    ///create a simple auction with `bidding time`
    ///seconds bidding time on the behalf of the 
    ///benificiary address`beneficaryAddress`

    constructor(
        uint biddingTime,
        address payable beneficaryAddress
    ){
        beneficiary = beneficaryAddress;
        auctionEndTime = block.timestamp + biddingTime;
    }


    /** 
    Bid on the auction with the value sent together
    with this transaction.
    The value will only be refunded if the auction is not won

    */

    function bid()external payable{
        if (block.timestamp> auctionEndTime)
            revert AuctionAlreadyEnded();

        /*
        If bid not higher, send the money back 
        revert the changes in this function execution
        including it having received the money
        */

        if (highestBid != 0){
            // Sending back the money by simply using
            // highestBidder.send(highestBid) is a security risk
            // because it could execute an untrusted contract.
            // It is always safer to let the recipients
            // withdraw their money themselves.
        }

        highestBidder =msg.sender;
        highestBid =msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);

    }
        
    ///withdraw a bid that was over bid.
    function withdraw() external returns(bool){
        uint amount = pendingReturns[msg.sender];
        if(amount> 0){
            //setting to zero because the recipient 
            //can call this function again as part of receiving call
            //before `send` returns.

            pendingReturns[msg.sender] = 0;
            if(!payable(msg.sender).send(amount)){
                //reseting the amount owning 
                pendingReturns[msg.sender] =amount;
                return false;
            }
        }
        return true;
    }
    
    ///End the auction and send the highest bid
    ///to the beneficiary

    function auctionEnd() external {
    /**
        conditions to test 
            */

        if (block.timestamp<auctionEndTime)
            revert AuctionNotYetEnded();
        if (ended)
            revert AuctionEndAlreadyCalled();
        //2. effect
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        

        //3. interaction
        beneficiary.transfer(highestBid);

    }

}