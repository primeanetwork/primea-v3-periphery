// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import '@primea/v3-core/contracts/interfaces/IPrimeaV3Pool.sol';
import '@primea/v3-core/contracts/interfaces/callback/IPrimeaV3SwapCallback.sol';
import '@primea/v3-core/contracts/interfaces/callback/IPrimeaV3MintCallback.sol';
import '@primea/v3-core/contracts/libraries/SafeCast.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import '../libraries/TransferHelper.sol';
import '../libraries/PoolAddress.sol';

contract TestPrimeaV3Callee is IPrimeaV3SwapCallback, IPrimeaV3MintCallback {
    using SafeCast for uint256;

    address public immutable factory;

    constructor(address _factory) {
        factory = _factory;
    }

    // Swap variants
    function swapExact0For1(address pool, uint256 amount0In, address recipient, uint160 sqrtPriceLimitX96) external {
        IPrimeaV3Pool(pool).swap(recipient, true, amount0In.toInt256(), sqrtPriceLimitX96, _encode(msg.sender));
    }

    function swap0ForExact1(address pool, uint256 amount1Out, address recipient, uint160 sqrtPriceLimitX96) external {
        IPrimeaV3Pool(pool).swap(recipient, true, -amount1Out.toInt256(), sqrtPriceLimitX96, _encode(msg.sender));
    }

    function swapExact1For0(address pool, uint256 amount1In, address recipient, uint160 sqrtPriceLimitX96) external {
        IPrimeaV3Pool(pool).swap(recipient, false, amount1In.toInt256(), sqrtPriceLimitX96, _encode(msg.sender));
    }

    function swap1ForExact0(address pool, uint256 amount0Out, address recipient, uint160 sqrtPriceLimitX96) external {
        IPrimeaV3Pool(pool).swap(recipient, false, -amount0Out.toInt256(), sqrtPriceLimitX96, _encode(msg.sender));
    }

    /// @inheritdoc IPrimeaV3MintCallback
    function primeaV3MintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external override {
        (address payer, address token0, address token1, uint24 fee) = abi.decode(data, (address, address, address, uint24));
        require(msg.sender == PoolAddress.computeAddress(factory, token0, token1, fee), "Invalid pool caller");

        if (amount0 > 0) {
            TransferHelper.safeTransferFrom(token0, payer, msg.sender, amount0);
        }
        if (amount1 > 0) {
            TransferHelper.safeTransferFrom(token1, payer, msg.sender, amount1);
        }
    }

    /// @inheritdoc IPrimeaV3SwapCallback
    function primeaV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external override {
        (address payer, address token0, address token1, uint24 fee) = abi.decode(data, (address, address, address, uint24));
        require(msg.sender == PoolAddress.computeAddress(factory, token0, token1, fee), "Invalid pool caller");

        if (amount0Delta > 0) {
            TransferHelper.safeTransferFrom(token0, payer, msg.sender, uint256(amount0Delta));
        }
        if (amount1Delta > 0) {
            TransferHelper.safeTransferFrom(token1, payer, msg.sender, uint256(amount1Delta));
        }
    }

    function primeaV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external override {
        revert("primeaV3FlashCallback not implemented");
    }

    /// Utility: ABI encode data for callbacks
    function _encode(address payer) internal view returns (bytes memory) {
        // Replace with actual pool data or use fixed token0, token1, fee for testing
        address token0 = address(0); // placeholder
        address token1 = address(0); // placeholder
        uint24 fee = 3000;           // placeholder fee tier
        return abi.encode(payer, token0, token1, fee);
    }
}
