// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import "./HbarToTokenPoolHTS.sol";

/// @title PoolFactory - Deploy and track HbarToTokenPoolHTS pools
contract PoolFactory {
    address public immutable warehouse;

    struct PoolInfo {
        string name;
        address pool;
        address rewardToken;
        uint256 depositEnd;
        uint256 rewardPerHbar;
    }

    PoolInfo[] public pools;

    event PoolCreated(
        uint256 indexed index,
        string name,
        address pool,
        address rewardToken,
        uint256 depositEnd,
        uint256 rewardPerHbar
    );

    modifier onlyWarehouse() {
        require(msg.sender == warehouse, "only warehouse");
        _;
    }

    constructor() {
        warehouse = msg.sender;
    }

    function createPool(
        string memory name,
        address rewardToken,
        uint256 depositDurationSeconds,
        uint256 rewardPerHbar
    ) external onlyWarehouse returns (address poolAddr) {
        HbarToTokenPoolHTS pool = new HbarToTokenPoolHTS(warehouse, rewardToken, depositDurationSeconds, rewardPerHbar);
        poolAddr = address(pool);

        PoolInfo memory info = PoolInfo({
            name: name,
            pool: poolAddr,
            rewardToken: rewardToken,
            depositEnd: pool.depositEnd(),
            rewardPerHbar: rewardPerHbar
        });
        pools.push(info);

        emit PoolCreated(pools.length - 1, name, poolAddr, rewardToken, info.depositEnd, rewardPerHbar);
    }

    function poolsCount() external view returns (uint256) {
        return pools.length;
    }
}


