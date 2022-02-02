//SPDX-License-Identifier:GPL-3.0
//Swapping token on uniswap
pragma solidity >=0.7.0;

//The ERC20 interface
interface IERC20{
    function totalSupply() external view return(uint);
    function balanceOf (address account) external view returns(uint);
    function transfer (address recipient, uint amount) external view returns(bool);
    function allowance (address owner, address spender) external view returns(uint);
    function approve (address spender, uint amount) external return (bool);
    function transferForm (
        address sender,
        address recipient,
        uint amount
    ) external returns(bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner , address indexed spender, uint value);


} 



//for the uiniswap router
// this allows the swapTokenForToken to work
interface IUniswapV2Router {
    function getAmountsOut(uint256 amountIn, address[] memorypath)
    external view returns(uint256[] memory amounts);

    function swapExatTokensForTokens(
        //amount of token we are sending in
        uint256 amountIn,
        //the minimum amount of token we want out of the trade
        uint256 amountOutMins,
        //list of token address we are going to trade in
        address[] calldata path,
        //this is the address we are going to sent the output token to
        address to,
        //the last time te trade is valid for
        uint deadline 
    ) external returns (uint256[memory amounts]);

}


interface IuniswapV2Pair{
    function token0() external view returns (address);
    function token1() external view returns (address);
    function swap(
        uint256 amount0Out,
        uint256 amount1out,
        address to,
        bytes calldata data
    ) external;
}

interface IuniswapV2Factory {
    function getPair(address token0, address token1) external returns (address);

}


contract tokenSwap {
    //address to uniswap v2 router
    address private constant UNISWAP_v2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    //address of WETH token.   
    //you might get a better price using WETH.  
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    
    //this function is used to trade form one token to another
    function swap(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMins, address to) external {
        //first we transfer the amount in token to this contract
        //this contract will have the amount on token in
        IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

        if (_tokenIn ==WETH || _tokenOut ==WETH){
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;

        }else{
            path =new address[](3)
            path[0] =_tokenIn;
            path[1] = WETH;
            path[2] = _tokenOut;
        }
        //calling the swarpExatTokensForTokens
        //block.timestamp set the latest time the trade is valid for
        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForToken(_amountIn, _amountOutMins, path, _to, block.timestamp);
    }
    // this function returns the minimum output from a swap
    //for the swap function above
    function getAmountOutMins(address _tokenIn, address _tokenOut, uint256 _amountIn) external view returns (uint256){
      //path is an array of addresses
      //this path array will have 3 address[tokenIn, WETH, tokenOut]
      address[] memory path;
      if (_tokenIn == WETH || _tokenOut == WETH){
          path = new address[](2);
          path[0] = _tokenIn;
          path[1] = _tokenOut;

      }else {
          path = new address[] (3);
          path[0] = _tokenIn;
          path[1] = WETH;
          path[2] = _tokenOut;
        }

    uint256[] memory amountOutMins = IUniswapV2Router(uniswap_V2_ROUTER).getAmountsOut(_amountIn, path);
    return amountOutMins[path.length -1]
    }

}