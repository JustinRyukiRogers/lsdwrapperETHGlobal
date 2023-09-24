// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RebasedToken is ERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) public lastUpdatedBlock;
    uint256 public growthRate = 1; // 1% growth rate

    constructor(string memory name, string memory symbol, address beneficiary) ERC20(name, symbol) {
        require(beneficiary != address(0), "Invalid beneficiary address");
        _mint(beneficiary, 100 * 10**decimals());
    }

    function balanceOf(address account) public view override returns (uint256) {
        uint256 storedBalance = super.balanceOf(account);
        
        if (storedBalance == 0) {
            return 0;
        }

        uint256 blocksPassed = block.number.sub(lastUpdatedBlock[account]);
        uint256 growth = storedBalance.mul(growthRate).div(100).mul(blocksPassed);
        
        return storedBalance.add(growth);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _updateBalance(msg.sender);
        _updateBalance(recipient);
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _updateBalance(sender);
        _updateBalance(recipient);
        return super.transferFrom(sender, recipient, amount);
    }

    function _updateBalance(address account) internal {
        uint256 newBalance = balanceOf(account);
        lastUpdatedBlock[account] = block.number;
    }
}
