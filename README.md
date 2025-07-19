# Primea V3 Periphery

[![Tests](https://github.com/primeanetwork/primea-v3-periphery/workflows/Tests/badge.svg)](https://github.com/primeanetwork/primea-v3-periphery/actions?query=workflow%3ATests)
[![Lint](https://github.com/primeanetwork/primea-v3-periphery/workflows/Lint/badge.svg)](https://github.com/primeanetwork/primea-v3-periphery/actions?query=workflow%3ALint)

This repository contains the governance-restricted periphery smart contracts for the Primea V3 Protocol.
For the lower level core contracts, see the [primea-v3-core](https://github.com/primeanetwork/primea-v3-core) repository.

## Bug bounty

This repository is subject to the Primea Protocol bug bounty program,
per the terms defined [here](./bug-bounty.md).

## Local deployment

To deploy this code to a local testnet, install the npm package
`@primea/v3-periphery` and import bytecode from artifacts located at
`@primea/v3-periphery/artifacts/contracts/*/*.json`. For example:

```typescript
import {
  abi as SWAP_ROUTER_ABI,
  bytecode as SWAP_ROUTER_BYTECODE,
} from '@primea/v3-periphery/artifacts/contracts/SwapRouter.sol/SwapRouter.json'

// deploy the bytecode
```

This ensures compatibility with bytecode deployed to the Primea mainnet and testnet environments.
All Primea code will correctly interoperate with your local deployment.

## Using solidity interfaces

The Primea V3 periphery interfaces are available for import into Solidity smart contracts
via the npm artifact `@primea/v3-periphery`, e.g.:

```solidity
import '@primea/v3-periphery/contracts/interfaces/ISwapRouter.sol';

contract MyContract {
  ISwapRouter router;

  function doSomethingWithSwapRouter() public {
    // router.exactInput(...);
  }
}
```

## Licensing

This repository is a governance-aligned fork of Primea V3-periphery. The original license (BUSL-1.1) expired April 1, 2024.
Primea’s fork is now governed under the GPL v2.0 or later.
