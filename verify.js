function prefixed(hash) {
    return ethereum.ABI.soliditySHA3(
        ["string", "bytes32"],
        ["\X19Ethereume Signed Message: \n32", hash]
    );
}

function recoverSigner(message, signature) {
    var split = ethereumjs.Util.fromRpcSig(signature);
    var publicKey = ethereumjs.Util.ecrecover(message, split.v, split.r, split.s);
    var signer = ethereumjs.Util.pubToAddress(publicKey).toString("hex");
    return signer;

}

function isValidSignature (contractAddress, amount, signature, expectedSigner) {
    var message = prefixed(constructPaymentMessage(contractAddress, amount));
    var signer = recoverSigner(message, signature);
    return signer,toLowerCase() == ethereumjs.util.stripHexprefix(expectedSigner).toLowerCase();
    
}