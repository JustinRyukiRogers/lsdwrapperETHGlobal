import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployContracts: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  // Deploy TokenFactory contract
  const tokenFactory = await deploy("TokenFactory", {
    from: deployer,
    args: [],
    log: true,
    autoMine: true,
  });

  // If you want to deploy an instance of LSDWrap during the deployment process, you can do so here.
  // Note: You'll need to provide the necessary constructor arguments for LSDWrap.
  // For this example, I'm leaving it commented out as you might want to deploy LSDWrap instances manually after setting allowed tokens in the TokenFactory.

  /*
  await deploy("LSDWrap", {
    from: deployer,
    args: ["LSDWrap Name", "LSDW", someUnderlyingTokenAddress, [listOfAllowedTokens], tokenFactory.address],
    log: true,
    autoMine: true,
  });
  */

  // Print out the address of the deployed TokenFactory
  console.log(`TokenFactory deployed to: ${tokenFactory.address}`);
};

export default deployContracts;

deployContracts.tags = ["TokenFactory", "LSDWrap"];
