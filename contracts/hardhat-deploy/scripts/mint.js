const hre = require('hardhat');
require('dotenv').config();

async function main() {
  const tokenAddress = process.env.BKN_TOKEN_ADDRESS;
  const recipient = process.env.MINT_TO;
  const amount = process.env.MINT_AMOUNT || '1000';

  if (!tokenAddress || !recipient) {
    throw new Error('Missing BKN_TOKEN_ADDRESS or MINT_TO in .env');
  }

  const token = await hre.ethers.getContractAt('BKNToken', tokenAddress);
  const decimals = await token.decimals();
  const tx = await token.mint(recipient, hre.ethers.parseUnits(amount, decimals));
  await tx.wait();

  console.log(`Minted ${amount} BKN to ${recipient}`);
  console.log(`Tx hash: ${tx.hash}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
