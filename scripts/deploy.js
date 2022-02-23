const main = async () => {
    const domainContractFactory = await hre.ethers.getContractFactory('Domains');
    const domainContract = await domainContractFactory.deploy("astro");
    await domainContract.deployed();
  
    console.log("Contract deployed to:", domainContract.address);
  
      let txn = await domainContract.register("baggle",  {value: hre.ethers.utils.parseEther('0.1')});
      await txn.wait();
    console.log("Minted domain baggle.astro");
  
    txn = await domainContract.setRecord("baggle", "https://twitter.com");
    await txn.wait();
    console.log("Set record for baggle.astro");
  
    const address = await domainContract.getAddress("baggle");
    console.log("Owner of domain baggle:", address);
  
    const balance = await hre.ethers.provider.getBalance(domainContract.address);
    console.log("Contract balance:", hre.ethers.utils.formatEther(balance));
  }
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();