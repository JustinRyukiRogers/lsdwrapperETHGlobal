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

  
  await deploy("LSDWrap", {
    from: deployer,
    args: ["LSDWrap Name", "LSDW", "0xE67ABDA0D43f7AC8f37876bBF00D1DFadbB93aaa", 1 * 10^21, 1*10^6, "0xA9D81201dc7599Df2990Dbf762Df7b9dD706A4a1"],
    log: true,
    autoMine: true,
});

  

  // Print out the address of the deployed TokenFactory
  console.log(`TokenFactory deployed to: ${tokenFactory.address}`);
};

export default deployContracts;

deployContracts.tags = ["TokenFactory", "LSDWrap"];
