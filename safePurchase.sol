//SPDX-License-Identifier:GNU-3.0
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
    event ItemReceived();
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
            state = State.Inactive;
            // We use transfer here directly. It is
            // reentrancy-safe, because it is the
            // last call in this function and we
            // already changed the state.
            seller.transfer(address(this).balance);
        }


        ///to confirm the purchase as the buyer,
        ///the transaction has to include  `2*value` ether.
        /// the ether will be locked until confirmReceived is called
 
        function confirmPurchase() 
        external
        inState(State.Created)
        condition(msg.value ==(2* value))
        payable
        {
            emit PurchaseConfirmed();
            buyer = payable(msg.sender);
            state = State.Locked;

        }
        ///confirm that you(the buyer) received the item.
        ///this will release the locked ether.

        function confirmReceived()
            external
            onlyBuyer()
            inState(State.Locked)
        {
            emit ItemReceived();
            //changing the state first because
            //otherwise, the contract called using `send` below 
            //can call in again here
            state =State.Release;
            buyer.transfer(value);

                  
        }
        ///this function refunds the seller, ie.
        ///pays back the locked funde of the seller.

        function refundSeller()
        external
        onlySeller
        inState(State.Release)
        {
            emit SellerRefunded();
            //changing the state first because
            //otherwise, the contracts called using `send` bellow
            //can call it again here
            state = State.Inactive;
            seller.transfer (3 *value);
            
        }
}