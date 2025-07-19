// SPDX-License-Identifier: GPL-2.0-or-later
import '@primea/v3-core/contracts/interfaces/IPrimeaV3Pool.sol';

pragma solidity >=0.6.0;

import '../libraries/PoolTicksCounter.sol';

contract PoolTicksCounterTest {
    using PoolTicksCounter for IPrimeaV3Pool;

    function countInitializedTicksCrossed(
        IPrimeaV3Pool pool,
        int24 tickBefore,
        int24 tickAfter
    ) external view returns (uint32 initializedTicksCrossed) {
        return pool.countInitializedTicksCrossed(tickBefore, tickAfter);
    }
}
