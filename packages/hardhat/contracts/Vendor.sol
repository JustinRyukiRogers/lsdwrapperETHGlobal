pragma solidity ^0.8.4;

import { Plugin } from "@1inch/token-plugins/contracts/ERC20Plugins.sol";

contract PluginExample is ERC20, Plugin {
    constructor(string memory name, string memory symbol, IERC20Plugins token_)
        ERC20(name, symbol)
        Plugin(token_)
    {} // solhint-disable-line no-empty-blocks

    function _updateBalances(address from, address to, uint256 amount) internal override {
        if (from == address(0)) {
            _mint(to, amount);
        } else if (to == address(0)) {
            _burn(from, amount);
        } else {
            _transfer(from, to, amount);
        }
    }
}

contract TokenConfig {
    // Wrapping and redemption rates
    uint256 public wrapRate;
    uint256 public redemptionRate;

    address public governance;

    modifier onlyGovernance() {
        require(msg.sender == governance, "Not authorized");
        _;
    }

    constructor(uint256 _wrapRate, uint256 _redemptionRate) {
        wrapRate = _wrapRate;
        redemptionRate = _redemptionRate;
        governance = msg.sender; // Initially set to the deployer
    }

    function setWrapRate(uint256 _wrapRate) external onlyGovernance {
        wrapRate = _wrapRate;
    }

    function setRedemptionRate(uint256 _redemptionRate) external onlyGovernance {
        redemptionRate = _redemptionRate;
    }

    function setGovernance(address _governance) external onlyGovernance {
        governance = _governance;
    }
}
