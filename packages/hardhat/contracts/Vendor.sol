pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Plugin.sol";

contract PluginExample is ERC20, Plugin {
    
    mapping(address => bool) public Members;

    constructor(string memory name, string memory symbol, IERC20Plugins token_)
        ERC20(name, symbol)
        Plugin(token_)
    {} // solhint-disable-line no-empty-blocks

    function _updateBalances(address from, address to, uint256 amount) internal override {
        if (from == address(0)) {
            _mint(to, amount*2);
        } else if (to == address(0)) {
            _burn(from, amount*2);
        } else {
            _burn(from, amount*2);
            _mint(to, amount);
        }

        if (balanceOf(from) >= 2 * 10^18) {
            Members[from] = true;
        } else {
            Members[from] = false;
        }

        if (balanceOf(to) >= 2 * 10^18) {
            Members[to] = true;
        } else {
            Members[to] = false;
        }
    }
}

