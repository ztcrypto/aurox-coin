// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/ICoin.sol";

contract StableCoinToken is ERC20, ICoin, Ownable {
    address public admin;
    constructor() ERC20("AUD Stablecoin", "AUDC") {
        admin = msg.sender;
    }

    function setAdmin(address _admin) external onlyOwner {
        require(_admin != address(0));
        admin = _admin;
        emit AdminTransfered(admin);
    }

    function mint(address account, uint256 amount) external override onlyAdmin returns(bool){
        _mint(account, amount);
        return true;
    }
    function burn(address account, uint256 amount) external override onlyAdmin returns(bool){
        _burn(account, amount);
        return true;
    }
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }
}