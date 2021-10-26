// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IVault.sol";
import "../interfaces/ICoin.sol";

contract UserVault is IVault {

    uint256 public price = 4000;
    ICoin public coin;
    mapping (address => Vault) private positions;
    uint256 public totalMinted;
    uint256 public totalCollateral;
    
    constructor(ICoin _coin){
        coin = _coin;
    }

   function deposit(uint256 amountToDeposit) external override payable {
       require(msg.value == amountToDeposit, "Deposit amount incorrect");
       uint256 amount = estimateTokenAmount(amountToDeposit);
       positions[msg.sender].collateralAmount += amountToDeposit;
       positions[msg.sender].debtAmount += amount;
       emit Deposit(amountToDeposit, amount);
       require(coin.mint(msg.sender, amount));
    }
    
    function withdraw(uint256 repaymentAmount) external override {
       uint256 amount = estimateCollateralAmount(repaymentAmount);
       positions[msg.sender].collateralAmount -= amount;
       positions[msg.sender].debtAmount -= repaymentAmount;
       emit Withdraw(repaymentAmount, amount);
       payable(msg.sender).transfer(amount);
       require(coin.burn(msg.sender, repaymentAmount));
    }
    
    function getVault(address userAddress) external override view returns(Vault memory vault) {
        return positions[userAddress];
    }
    
    function estimateCollateralAmount(uint256 repaymentAmount) public override view returns(uint256 collateralAmount) {
       require(repaymentAmount <= positions[msg.sender].debtAmount, "Repay amount overflow");
        collateralAmount = repaymentAmount / price;
        if (collateralAmount >  positions[msg.sender].collateralAmount) collateralAmount = positions[msg.sender].collateralAmount;
    }
    
    function estimateTokenAmount(uint256 depositAmount) public override view returns(uint256 tokenAmount) {
        Vault memory position = positions[msg.sender];
        if ((position.collateralAmount + depositAmount) * price < position.debtAmount) tokenAmount = 0; 
        else tokenAmount = (position.collateralAmount + depositAmount) * price - position.debtAmount;
    }
}
