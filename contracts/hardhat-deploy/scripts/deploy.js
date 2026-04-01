const hre = require('hardhat');

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const Token = await hre.ethers.getContractFactory('BKNToken');
  const token = await Token.deploy();
  await token.waitForDeployment();
  const address = await token.getAddress();

  console.log('BKNToken deployed to:', address);
  console.log('Owner/deployer:', deployer.address);
  console.log('Network:', hre.network.name);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
