// pragma solidity ^0.8.4;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


// contract TokenConfig {
//     // Wrapping and redemption rates
//     uint256 public wrapRate;
//     uint256 public redemptionRate;

//     address public governance;

//     modifier onlyGovernance() {
//         require(msg.sender == governance, "Not authorized");
//         _;
//     }

//     constructor(uint256 _wrapRate, uint256 _redemptionRate) {
//         wrapRate = _wrapRate;
//         redemptionRate = _redemptionRate;
//         governance = msg.sender; // Initially set to the deployer
//     }

//     function setWrapRate(uint256 _wrapRate) external onlyGovernance {
//         wrapRate = _wrapRate;
//     }

//     function setRedemptionRate(uint256 _redemptionRate) external onlyGovernance {
//         redemptionRate = _redemptionRate;
//     }

//     function setGovernance(address _governance) external onlyGovernance {
//         governance = _governance;
//     }
// }
