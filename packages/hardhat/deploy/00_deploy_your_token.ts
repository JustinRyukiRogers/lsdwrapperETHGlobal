import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployContracts: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  // Deploy TokenFactory contract
  const tokenFactoryDeployment = await deploy("TokenFactory", {
    from: deployer,
    args: [],
    log: true,
    autoMine: true,
  });

  // Deploy LSDWrap contract using the address of the just-deployed TokenFactory
  const lsdWrapDeployment = await deploy("LSDWrap", {
    from: deployer,
    args: [
      "WETH DAO", 
      "WEDAO", 
      "0xE67ABDA0D43f7AC8f37876bBF00D1DFadbB93aaa", // Example underlying token address
      tokenFactoryDeployment.address
    ],
    log: true,
    autoMine: true,
  });

  // Deploy PluginExample using the address of the just-deployed LSDWrap as the token
  await deploy("PluginExample", {
    from: deployer,
    args: ["Membership", "MMBR", lsdWrapDeployment.address],
    log: true,
    autoMine: true,
  });

  // Deploy RebasedToken
  const RebaseToken = await deploy("RebasedToken", {
    from: deployer,
    args: ["RebasedTokenName", "RTKN", "0x4dDd8F7371Bb05CCa7eEdfF260931586F0c6A0F3"], // This will mint 100 tokens to the deployer's address
    log: true,
    autoMine: true,
  });

  // Deploy LSDWrap contract using the address of the just-deployed TokenFactory
  const lsdWrapRebaseDeployment = await deploy("LSDWrap1", {
    from: deployer,
    args: [
      "Wrapped Rebased Token", 
      "WRTKN", 
      RebaseToken.address, // Example underlying token address 
      tokenFactoryDeployment.address
    ],
    log: true,
    autoMine: true,
  });  

  // Print out the addresses of the deployed contracts
  console.log(`TokenFactory deployed to: ${tokenFactoryDeployment.address}`);
  console.log(`LSDWrap deployed to: ${lsdWrapDeployment.address}`);
};

export default deployContracts;

deployContracts.tags = ["TokenFactory", "LSDWrap_WETH", "PluginExample", "RebasedToken", "LSDWrap_Rebased"];

