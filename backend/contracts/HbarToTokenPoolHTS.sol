// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

/// @title HbarToTokenPoolHTS - Accept HBAR deposits and distribute HTS token rewards
/// @notice Buyers deposit HBAR during a period; only the warehouse can distribute rewards in HTS tokens
/// @dev Uses Hedera Token Service precompile at address 0x167 to transfer tokens
interface IHederaTokenService {
    /// @dev Transfers `amount` of `token` from `accountFrom` to `accountTo`.
    /// Returns 22 (SUCCESS) on success. Amount is int64 (token base units).
    function transferToken(address token, address accountFrom, address accountTo, int64 amount) external returns (int64);
    /// @dev Associate `account` with `token`. Returns 22 (SUCCESS) on success.
    function associateToken(address account, address token) external returns (int64);
}

contract HbarToTokenPoolHTS {
    // HTS precompile address on Hedera
    address private constant HTS_PRECOMPILE = address(uint160(uint256(0x167)));

    // Pool parameters
    address public immutable warehouse; // issuer/owner/treasury signer
    address public immutable rewardToken; // HTS token as solidity address
    uint256 public immutable depositEnd; // unix timestamp when deposits stop

    // Reward: tokens per 1 HBAR, expressed in token base units per HBAR
    // reward = depositedTinybar * rewardPerHbar / 1e8
    uint256 public immutable rewardPerHbar;

    // Accounting
    mapping(address => uint256) public depositedTinybarByBuyer;
    address[] public buyers;
    mapping(address => bool) private isKnownBuyer;
    uint256 public totalDepositedTinybar;
    bool public rewardsDistributed;

    event Deposited(address indexed buyer, uint256 tinybarAmount);
    event RewardsDistributed(uint256 totalBuyers);

    modifier onlyWarehouse() {
        require(msg.sender == warehouse, "only warehouse");
        _;
    }

    constructor(
        address warehouse_,
        address rewardToken_,
        uint256 depositDurationSeconds,
        uint256 rewardPerHbar_
    ) {
        require(warehouse_ != address(0) && rewardToken_ != address(0), "zero addr");
        warehouse = warehouse_;
        rewardToken = rewardToken_;
        depositEnd = block.timestamp + depositDurationSeconds;
        rewardPerHbar = rewardPerHbar_;
    }

    /// @notice Deposit HBAR into the pool as a buyer during the deposit window
    function deposit() external payable {
        require(block.timestamp <= depositEnd, "deposit closed");
        require(msg.value > 0, "no hbar");

        if (!isKnownBuyer[msg.sender]) {
            isKnownBuyer[msg.sender] = true;
            buyers.push(msg.sender);
        }
        depositedTinybarByBuyer[msg.sender] += msg.value; // msg.value is tinybar
        totalDepositedTinybar += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Distribute rewards in HTS tokens to buyers according to their deposited HBAR
    /// @dev Requires this contract to hold sufficient rewardToken balance and each buyer to be associated with rewardToken
    function distributeRewards() external onlyWarehouse {
        require(block.timestamp > depositEnd, "too early");
        require(!rewardsDistributed, "already distributed");

        IHederaTokenService hts = IHederaTokenService(HTS_PRECOMPILE);

        uint256 numBuyers = buyers.length;
        for (uint256 i = 0; i < numBuyers; i++) {
            address buyer = buyers[i];
            uint256 tinybar = depositedTinybarByBuyer[buyer];
            if (tinybar == 0) continue;

            // reward = tinybar * rewardPerHbar / 1e8 (tinybar per hbar)
            uint256 reward = (tinybar * rewardPerHbar) / 1e8;

            if (reward == 0) continue;

            // HTS uses int64 token base units
            require(reward <= uint256(int256(type(int64).max)), "reward too large");
            int64 amount = int64(int256(reward));

            // Transfer from this contract (it must have token balance) to buyer
            int64 rc = hts.transferToken(rewardToken, address(this), buyer, amount);
            require(rc == 22, "hts transfer failed");
        }

        rewardsDistributed = true;
        emit RewardsDistributed(numBuyers);
    }

    /// @notice Associate this contract with the reward token via HTS precompile
    /// @dev Must be called once by the warehouse before funding/distribution
    function associateSelf() external onlyWarehouse {
        IHederaTokenService hts = IHederaTokenService(HTS_PRECOMPILE);
        int64 rc = hts.associateToken(address(this), rewardToken);
        require(rc == 22 || rc == 125, "associate failed");
    }

    /// @notice Pull tokens from the warehouse into this contract via HTS precompile
    /// @dev The transaction executing this function must include the warehouse signature
    function fundFromWarehouse(int64 amount) external onlyWarehouse {
        require(amount > 0, "amount");
        IHederaTokenService hts = IHederaTokenService(HTS_PRECOMPILE);
        int64 rc = hts.transferToken(rewardToken, warehouse, address(this), amount);
        require(rc == 22, "fund transfer failed");
    }

    /// @notice No HBAR withdrawals; funds are locked in the contract
    receive() external payable {
        // Accept direct HBAR top-ups (e.g., from warehouse) but buyers should call deposit()
        // Intentionally no withdraw function to enforce pool rules
    }

    function buyersCount() external view returns (uint256) {
        return buyers.length;
    }
}


