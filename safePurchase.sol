//SPDX-License-Identfier:GNU-3.0
pragma solidity >= 0.8;
contract Purchase{
    uint public value;
    address payable public seller;
    address payable public buyer;

    enum State {Created, Locked, Release,Inactive}
    //The state varible has a default value of the first member, `State.created`
    State public state;

    modifier condition (bool condition_){
        require(condition_);
        _;
    }

    ///only the buyer can call this function
    error OnlyBuyer();
    ///only the seller can call this function.
    error OnlySeller();
    /// the function cannot be called at the current state
    error InvalidState();
    /// the provided value has to be even
    error ValueNotEven();

    modifier onlyBuyer(){
        if (msg.sender != buyer)
        revert OnlyBuyer();
        _;
    }
    modifier onlySeller(){
        if (msg.sender != seller)
        revert OnlySeller();
        _;
    }
    modifier inState(State state_) {
        if(state != state_)
        revert InvalidState();
        _;
    }

    event Aborted();
    event PurchaseConfirmed();
    event ItemReciever();
    event SellerRefunded();

    //Ensure that `msg.value` is an even number
    //devision will truncate if it is an odd number.
    //check via multiplication that it wasn't an odd number.


    constructor() payable{
        seller = payable(msg.sender);
        value = msg.value/2;


        if((2*value) != msg.value)
        revert ValueNotEven();

    }

    ///Abort the purchase and reclaim the ether
    ///can only be called by the seller before the contract is locked

    function Abort()
        external
        onlySeller
        inState(State.Created)
        {
            emit Aborted();
            state =State.Inactive;
            
            seller.transfer(address(this).balance);
        }
        ///to confirm the purchase as the buyer,
        ///the transaction has to include  `2*value` ether.
        /// the ether will be locked until confirmReceived is called
 
        function confirmPurchase() external inState(State.Created)

        

}