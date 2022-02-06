// // var hash = web3utils.sha3("mesage to be signed");
// // web3utils.eth.personal.sign(hash,web3.eth.defaultAccount, function() {console.log("signed");
// // });
// //
// // recipient is the address that should be paid.
// // amount, in wei, specifies how much ether should be sent.
// // nonce can be any unique number to prevent replay attacks
// // contractAddress is used to prevent cross-contract replay attacks

// function signPayment(recipient, amount, nonce, contractAddress, callback) {
//     var hash ="0x" + abi.soliditySHA3(
//         ["address", "uint256", "uint256", "address"],
//         [recipient, amount,nonce, contractAddress]
//     ).toString("hex");
//     web3.eth.personal.sign(hash, web3.eth.defaultAddress, callback)
// }


//signature

function constructPaymentMessage(contractAddress, amount) {
    return abi.soliditySHA3(
        ["address", "uint256"],
        [contractAddress, amount]

    );
}

function signedMessage(message, callback) {
    web3.eth.personal.sign(
        "0x" + message.toString("hex"),
        web.eth.defaultAccount,
        callback
    );
}

//contract address is used to prevent cross-contract attack
function signPayment(contractAddress, amount, callback) {
    var message = constructPaymentMessage(contractAddress, amount);
    signedMessage(message, callback)
}