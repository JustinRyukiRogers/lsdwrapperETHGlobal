pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {ERC20Plugins} from "./ERC20Plugins.sol";

contract LSDWrap is ERC20Plugins, Ownable {
    using SafeMath for uint256;

    address public factoryOwner;
    uint256 private _initialCap;
    uint256 private _growthRate; // in tokens per second
    uint256 private _startTime;
    IERC20 public underlyingToken;

    constructor(
        string memory name,
        string memory symbol,
        IERC20 _underlyingToken,
        uint256 initialCap_,
        uint256 growthRate_,
        address _factoryOwner
    ) ERC20(name, symbol)
      ERC20Plugins(1000, 999999) // Add this line
      Ownable() {
        require(initialCap_ > 0, "Initial cap must be greater than 0");
        underlyingToken = _underlyingToken;  // Assign the passed token to the state variable
        _initialCap = initialCap_;
        _growthRate = growthRate_;
        _startTime = block.timestamp;
    }
    
    function cap() public view returns (uint256) {
        uint256 elapsedTime = block.timestamp - _startTime;
        return _initialCap + (_growthRate * elapsedTime);
    }

    function wrap(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");

        uint256 totalUnderlying = underlyingToken.balanceOf(address(this));
        uint256 proportion = (totalSupply()+1).div(totalUnderlying+1);

        uint256 tokensToMint = amount.mul(proportion);
        require(totalSupply() + tokensToMint <= cap(), "ERC20: cap exceeded");

        // Transfer the underlying tokens from the user to this contract
        require(underlyingToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        _mint(msg.sender, tokensToMint); // Mint the new tokens to the user
    }

    function unwrap(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        _burn(msg.sender, amount); // Burn the wrapped tokens
        uint256 totalUnderlying = underlyingToken.balanceOf(address(this));
        uint256 proportion = amount.div(totalSupply());
        uint256 tokenstosend = proportion.mul(totalUnderlying);
        require(tokenstosend <= underlyingToken.balanceOf(address(this)), "Not enough underlying tokens");
        // Transfer the underlying tokens back to the user
        require(underlyingToken.transfer(msg.sender, tokenstosend), "Transfer failed");

    }
}




contract TokenFactory is Ownable {
    address[] public createdTokens;
    IERC20[] public masterAllowedTokens;
    bool public ownershipAssigned = false;

    event MasterTokenAdded(IERC20 token);
    event WrappedTokenCreated(address wrappedToken, IERC20 underlyingToken);

    function addMasterAllowedToken(IERC20 token) public {
        require(!isMasterAllowedToken(token), "Token already in master list");
        if (ownershipAssigned) {
            require(msg.sender == owner(), "Only the owner can add tokens");
        }
        masterAllowedTokens.push(token);
        emit MasterTokenAdded(token);
    }

    function getMasterAllowedTokens() public view returns (IERC20[] memory) {
        return masterAllowedTokens;
    }

    function createWrappedToken(
        string memory name,
        string memory symbol,
        IERC20 selectedUnderlyingToken,
        uint256 cap,
        uint256 growthRate
    ) public returns (address) {
        require(isMasterAllowedToken(selectedUnderlyingToken), "Token not in master allowed list");
        LSDWrap newToken = new LSDWrap(name, symbol, selectedUnderlyingToken, cap, growthRate, msg.sender);
        createdTokens.push(address(newToken));
        emit WrappedTokenCreated(address(newToken), selectedUnderlyingToken);
        return address(newToken);
    }

    function isMasterAllowedToken(IERC20 token) internal view returns (bool) {
        for (uint i = 0; i < masterAllowedTokens.length; i++) {
            if (masterAllowedTokens[i] == token) {
                return true;
            }
        }
        return false;
    }

    function getCreatedTokens() public view returns (address[] memory) {
        return createdTokens;
    }
    
    function transferOwnership(address newOwner) public override onlyOwner {
        super.transferOwnership(newOwner);
        ownershipAssigned = true;
    }
}
