pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {ERC20Plugins} from "./ERC20Plugins.sol";


contract LSDWrap is ERC20Plugins, Ownable {
    using SafeMath for uint256;

    address public factoryOwner;
    IERC20 public underlyingToken;

    constructor(
        string memory name,
        string memory symbol,
        IERC20 _underlyingToken,
        address _factoryOwner
    ) ERC20(name, symbol)
      ERC20Plugins(1000, 999999) // Add this line
      Ownable() {
        underlyingToken = _underlyingToken;  // Assign the passed token to the state variable
    }

    function wrap(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");

        uint256 totalUnderlying = underlyingToken.balanceOf(address(this));
        uint256 proportion = (totalSupply()+1).div(totalUnderlying+1);

        uint256 tokensToMint = amount.mul(proportion);

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


contract LSDWrap1 is ERC20Plugins, Ownable {
    using SafeMath for uint256;

    address public factoryOwner;
    IERC20 public underlyingToken;

    constructor(
        string memory name,
        string memory symbol,
        IERC20 _underlyingToken,
        address _factoryOwner
    ) ERC20(name, symbol)
      ERC20Plugins(1000, 999999) // Add this line
      Ownable() {
        underlyingToken = _underlyingToken;  // Assign the passed token to the state variable
    }

    function wrap(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");

        uint256 totalUnderlying = underlyingToken.balanceOf(address(this));
        uint256 proportion = ((totalSupply()*10**18)+1).div((totalUnderlying)+1);

        uint256 tokensToMint; // Declare tokensToMint here

        if (totalSupply() == 0) { // Use '==' for comparison
            tokensToMint = amount.mul(proportion);
        }
        else {
            tokensToMint = amount.mul(proportion).div(10**18);
        }

        // Transfer the underlying tokens from the user to this contract
        require(underlyingToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        _mint(msg.sender, tokensToMint); // Mint the new tokens to the user
    }

    function unwrap(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");

        uint256 totalUnderlying = underlyingToken.balanceOf(address(this));
        uint256 proportion = amount.mul(10**18).div(totalSupply());
        uint256 tokenstosend = proportion.mul(totalUnderlying.div(10**18));
        require(tokenstosend <= underlyingToken.balanceOf(address(this)), "Not enough underlying tokens");
        // Transfer the underlying tokens back to the user

        require(underlyingToken.transfer(msg.sender, tokenstosend), "Transfer failed");
        _burn(msg.sender, amount); // Burn the wrapped tokens
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
        IERC20 selectedUnderlyingToken
    ) public returns (address) {
        require(isMasterAllowedToken(selectedUnderlyingToken), "Token not in master allowed list");
        LSDWrap newToken = new LSDWrap(name, symbol, selectedUnderlyingToken, msg.sender);
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
