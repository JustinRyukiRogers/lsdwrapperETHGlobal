pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";

// learn more: https://docs.openzeppelin.com/contracts/4.x/erc20

contract LSDWrap is ERC20, ERC20Wrapper {
    address public factoryOwner;

    constructor(
        string memory name,
        string memory symbol,
        IERC20 underlyingToken,
        address _factoryOwner
    ) ERC20(name, symbol) ERC20Wrapper(underlyingToken) {
        factoryOwner = _factoryOwner;
    }

    // Override decimals function to resolve ambiguity
    function decimals() public view virtual override(ERC20, ERC20Wrapper) returns (uint8) {
        return super.decimals();
    }
    
    function wrap(uint256 amount) public {
        depositFor(msg.sender, amount);
    }

    function unwrap(uint256 amount) public {
        withdrawTo(msg.sender, amount);
    }
}

contract TokenFactory is Ownable {
    address[] public createdTokens;
    IERC20[] public masterAllowedTokens; // Centralized array of allowed token addresses
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
    
    // Override the transferOwnership function to set ownershipAssigned to true
    function transferOwnership(address newOwner) public override onlyOwner {
        super.transferOwnership(newOwner);
        ownershipAssigned = true;
    }
}

