// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
pragma abicoder v2;

import '@primea/v3-core/contracts/interfaces/callback/IPrimeaV3FlashCallback.sol';
import '@primea/v3-core/contracts/libraries/LowGasSafeMath.sol';

import '../base/PeripheryPayments.sol';
import '../base/PeripheryImmutableState.sol';
import '../libraries/PoolAddress.sol';
import '../libraries/CallbackValidation.sol';
import '../libraries/TransferHelper.sol';
import '../interfaces/ISwapRouter.sol';

/// @title Flash contract implementation
/// @notice An example contract using the Primea V3 flash function
contract PairFlash is IPrimeaV3FlashCallback, PeripheryPayments {
    using LowGasSafeMath for uint256;
    using LowGasSafeMath for int256;

    ISwapRouter public immutable swapRouter;

    constructor(
        ISwapRouter _swapRouter,
        address _factory,
        address _WETH9
    ) PeripheryImmutableState(_factory, _WETH9) {
        swapRouter = _swapRouter;
    }

    struct FlashCallbackData {
        uint256 amount0;
        uint256 amount1;
        address payer;
        PoolAddress.PoolKey poolKey;
        uint24 poolFee2;
        uint24 poolFee3;
    }

    /// @inheritdoc IPrimeaV3FlashCallback
    function primeaV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external override {
        FlashCallbackData memory decoded = abi.decode(data, (FlashCallbackData));
        CallbackValidation.verifyCallback(factory, decoded.poolKey);

        address token0 = decoded.poolKey.token0;
        address token1 = decoded.poolKey.token1;

        uint256 amount0Min = decoded.amount0.add(fee0);
        uint256 amount1Min = decoded.amount1.add(fee1);

        // 1. Swap token1 → token0 (using poolFee2)
        TransferHelper.safeApprove(token1, address(swapRouter), decoded.amount1);
        uint256 amountOut0 = swapRouter.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: token1,
                tokenOut: token0,
                fee: decoded.poolFee2,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: decoded.amount1,
                amountOutMinimum: amount0Min,
                sqrtPriceLimitX96: 0
            })
        );

        // 2. Swap token0 → token1 (using poolFee3)
        TransferHelper.safeApprove(token0, address(swapRouter), decoded.amount0);
        uint256 amountOut1 = swapRouter.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: token0,
                tokenOut: token1,
                fee: decoded.poolFee3,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: decoded.amount0,
                amountOutMinimum: amount1Min,
                sqrtPriceLimitX96: 0
            })
        );

        // 3. Repay the flash loan
        if (amount0Min > 0) pay(token0, address(this), msg.sender, amount0Min);
        if (amount1Min > 0) pay(token1, address(this), msg.sender, amount1Min);

        // 4. Transfer profit (if any)
        if (amountOut0 > amount0Min) pay(token0, address(this), decoded.payer, amountOut0 - amount0Min);
        if (amountOut1 > amount1Min) pay(token1, address(this), decoded.payer, amountOut1 - amount1Min);
    }

    struct FlashParams {
        address token0;
        address token1;
        uint24 fee1;
        uint256 amount0;
        uint256 amount1;
        uint24 fee2;
        uint24 fee3;
    }

    function initFlash(FlashParams memory params) external {
        PoolAddress.PoolKey memory poolKey = PoolAddress.PoolKey({
            token0: params.token0,
            token1: params.token1,
            fee: params.fee1
        });

        IPrimeaV3Pool pool = IPrimeaV3Pool(PoolAddress.computeAddress(factory, poolKey));

        pool.flash(
            address(this),
            params.amount0,
            params.amount1,
            abi.encode(
                FlashCallbackData({
                    amount0: params.amount0,
                    amount1: params.amount1,
                    payer: msg.sender,
                    poolKey: poolKey,
                    poolFee2: params.fee2,
                    poolFee3: params.fee3
                })
            )
        );
    }
}
