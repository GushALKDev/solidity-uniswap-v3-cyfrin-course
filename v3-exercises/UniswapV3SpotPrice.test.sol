pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {IUniswapV3Pool} from
    "../../../src/interfaces/uniswap-v3/IUniswapV3Pool.sol";
import {UNISWAP_V3_POOL_USDC_WETH_500} from "../../../src/Constants.sol";
import {FullMath} from "../../../src/uniswap-v3/FullMath.sol";

contract UniswapV3SwapTest is Test {
    // token0 (X)
    uint256 private constant USDC_DECIMALS = 1e6;
    // token1 (Y)
    uint256 private constant WETH_DECIMALS = 1e18;
    // 1 << 96 = 2 ** 96
    uint256 private constant Q96 = 1 << 96;
    IUniswapV3Pool private immutable pool =
        IUniswapV3Pool(UNISWAP_V3_POOL_USDC_WETH_500);

    // Exercise 1
    // - Get price of WETH in terms of USDC and return price with 18 decimals
    function test_spot_price_from_sqrtPriceX96() public {
        uint256 price = 0;
        IUniswapV3Pool.Slot0 memory slot0 = pool.slot0();

        // Write your code here
        // Don’t change any other code

        uint256 sqrtPriceX96 = slot0.sqrtPriceX96;

        // P = Y / X
        // Price of USDC in terms of WETH

        // 1 / P = X / Y
        // Price of WETH in terms of USDC

        // P has 1e18 / 1e6 = 1e12 decimals
        // 1 / P has 1e6 / 1e18 = 1e-12 decimals

        // sqrtPriceX96 = sqrt(P) * Q96
        // Q96 = 2^96
        // sqrtPriceX96 * sqrtPriceX96 = sqrt(P) * Q96 * sqrt(P) * Q96
        // sqrtPriceX96 * sqrtPriceX96 = P * Q96 * Q96
        // P = (sqrtPriceX96 * sqrtPriceX96) / (Q96 * Q96)
        // P = (sqrtPriceX96 * sqrtPriceX96) / Q96^2

        price = FullMath.mulDiv(sqrtPriceX96, sqrtPriceX96, Q96**2);

        // Inverse price calculation with decimal adjustment:
        // - price currently contains P (USDC/WETH price)
        // - We need 1/P (WETH/USDC price) for the exercise
        // Since price has 1e12 decimals, we need to adjust to get 18 decimals in final result
        // - 1/price: Mathematical inversion (1/P)
        // - 1e18: Scale to get 18 decimal precision in final result
        // - 1e12: Compensate for the 12 decimals of price in the denominator
        // price = 1e18 * 1e12 / price;
        // Result: WETH price in USDC with 18 decimal precision
        
        price = 1e18 * 1e12 / price; // 1/P with 18 decimals

        assertGt(price, 0, "price = 0");
        console2.log("price %e", price);
    }
}