// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * Author: NEXTECHARHITECT
 * (Smart Contract Developer and Solidity, Foundry, Web3 Engineering)
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SisoToken is ERC20, ERC20Burnable, Pausable, Ownable {
    
    constructor(
        uint256 initialSupply
    ) ERC20("SISO Token", "SISO") Ownable(msg.sender) {
        if (initialSupply > 0) {
            _mint(msg.sender, initialSupply);
        }
    }

    /**
     * @notice Mint new tokens (owner only)
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @notice Pause all token transfers (owner only)
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause token transfers (owner only)
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._update(from, to, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }
}
