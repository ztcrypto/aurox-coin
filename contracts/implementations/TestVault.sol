// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./UserVault.sol";

contract TestVault is UserVault, Ownable {
    
    constructor(ICoin _coin) UserVault(_coin) {
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }
}
