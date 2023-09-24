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
      "LSDWrap Name", 
      "LSDW", 
      "0xE67ABDA0D43f7AC8f37876bBF00D1DFadbB93aaa", // Example underlying token address
      1000*10^18, 
      0.5*10^17, 
      tokenFactoryDeployment.address
    ],
    log: true,
    autoMine: true,
  });

  // Deploy PluginExample using the address of the just-deployed LSDWrap as the token
  await deploy("PluginExample", {
    from: deployer,
    args: ["PluginExampleTokenName", "PET", lsdWrapDeployment.address],
    log: true,
    autoMine: true,
  });

  // Print out the addresses of the deployed contracts
  console.log(`TokenFactory deployed to: ${tokenFactoryDeployment.address}`);
  console.log(`LSDWrap deployed to: ${lsdWrapDeployment.address}`);
};

export default deployContracts;

deployContracts.tags = ["TokenFactory", "LSDWrap", "PluginExample"];
