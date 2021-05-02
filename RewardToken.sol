pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
/**
 * @title SimpleBurnableToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract RewardingToken is ERC20 , Ownable  {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
     constructor(address _owner, uint256 _supply) public ERC20("RewardToken", "RDT") { 
         
        _mint(_owner, _supply);
    }
    
     function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
   
    }

    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
      
    }
}