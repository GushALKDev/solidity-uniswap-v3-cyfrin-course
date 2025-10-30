# Uniswap V3 Spot Price Exercise

## Introduction

Calculate the spot price of WETH in terms of USDC from Uniswap V3's `sqrtPriceX96` value with 18 decimal precision.

**Pool**: USDC/WETH (0.05% fee) | **Token0**: USDC (6 decimals) | **Token1**: WETH (18 decimals)

## Mathematical Foundation

### sqrtPriceX96 Representation
```
sqrtPriceX96 = sqrt(P) * 2^96
where P = token1_reserves / token0_reserves (USDC price in WETH terms)
```

### The Challenge
- **P**: USDC price in WETH terms (what we calculate first)
- **1/P**: WETH price in USDC terms (what we need for the exercise)
- **Decimal adjustment**: P has 1e12 decimals, 1/P has 1e-12 decimals (too small)

## Solution Steps

### Step 1: Calculate P from sqrtPriceX96
```solidity
// P = (sqrtPriceX96)^2 / (2^96)^2
price = FullMath.mulDiv(sqrtPriceX96, sqrtPriceX96, Q96**2);
```

**Key insight**: We divide by `Q96²` because:
- `sqrtPriceX96² = P × 2^192`
- To get P: `sqrtPriceX96² / 2^192 = sqrtPriceX96² / (2^96)²`

### Step 2: Invert Price with Decimal Adjustment
```solidity
price = 1e18 * 1e12 / price;
```

**Breaking down the calculation**:
- `1e18`: Target precision (18 decimals)
- `1e12`: Compensates for WETH(18) - USDC(6) decimal difference  
- `/price`: Mathematical inversion (1/P)

## Technical Implementation

### Complete Solution
```solidity
function test_spot_price_from_sqrtPriceX96() public {
    uint256 price = 0;
    IUniswapV3Pool.Slot0 memory slot0 = pool.slot0();
    uint256 sqrtPriceX96 = slot0.sqrtPriceX96;

    // Calculate P from sqrtPriceX96
    price = FullMath.mulDiv(sqrtPriceX96, sqrtPriceX96, Q96**2);
    
    // Invert price with decimal adjustment
    price = 1e18 * 1e12 / price;

    assertGt(price, 0, "price = 0");
    console2.log("price %e", price);
}
```

### Why FullMath.mulDiv?
Prevents overflow during `sqrtPriceX96²` calculation (192 bits) while maintaining full precision.

### Result Interpretation
- **Output**: USDC per 1 WETH with 18 decimal precision
- **Example**: `3500000000000000000000` = ~3,500 USDC per WETH

## Key Concepts

1. **sqrtPriceX96**: Space-efficient price storage using square root and bit shifting
2. **Decimal Management**: Essential when working with tokens of different precisions
3. **Price Inversion**: Converting between token pair denominations
4. **Overflow Safety**: Using specialized math libraries for large number operations

## Practice Exercises

1. Calculate USDC price in WETH terms (don't invert)
2. Implement tick-based price calculation
3. Compare with TWAP (Time-Weighted Average Price)
4. Handle different decimal combinations (e.g., WBTC/USDT)
