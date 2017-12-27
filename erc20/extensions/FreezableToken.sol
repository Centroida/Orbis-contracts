pragma solidity ^0.4.18;

import '../ERC20Standard.sol';
import '../../modifiers/Ownable.sol';

/**
 * @title FreezableToken
 * @dev ERC20Standard modified with freezing accounts ability.
 */
contract FreezableToken is ERC20Standard, Ownable {

    event FrozenFunds(address indexed _target, uint256 _amount);

    event UnfrozenFunds(address indexed _target, uint256 _amount);
    
    function FreezableToken(address _dataStorageAddress, address _ledgerAddress) ERC20Standard(_dataStorageAddress, _ledgerAddress) public {}
    
    /**
     * @dev Prevent target address from sending & receiving tokens.
     * @param _target Address to be frozen.
     * @return success True if the operation was successful, or throws. 
     * @return amount The amount of tokens which were frozen.
     */ 
    function freezeAccount(address _target) public onlyOwners returns (bool success, uint256 amount) {
        require(_target != address(0));
        (success, amount) = dataStorage.setFrozenAccount(_target, true);
        require(success);
        FrozenFunds(_target, amount);
    }

    /**
     * @dev Allow target address from sending & receiving tokens.
     * @param _target Address to be unfrozen.
     * @return success True if the operation was successful, or throws. 
     * @return amount The amount of tokens which were unfrozen.
     */ 
    function unfreezeAccount(address _target) public onlyOwners returns (bool success, uint256 amount) {
        require(_target != address(0));
        (success, amount) = dataStorage.setFrozenAccount(_target, false);
        require(success);
        UnfrozenFunds(_target, amount);
    }

    /**
     * @dev Checks whether the target is frozen or not.
     * @param _target Address to check.
     * @return isFrozen A boolean that indicates whether the account is frozen or not. 
     * @return amount Balance of the account.
     */
    function isAccountFrozen(address _target) public view returns (bool isFrozen, uint256 amount) {
        return dataStorage.getFrozenAccount(_target); // AUDIT: If you remove the amount from the dataStorage method you might use dataStorage.getBalance() to get the second param and still keep it all constant
    }

    /* AUDIT: It might be a bit better to do this logic with a modifier onlyNotFrozen */
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
        bool isFromFrozen;
        (isFromFrozen,) = dataStorage.getFrozenAccount(_from); // AUDIT: If you remove the amount from the dataStorage method the three rows can be done in 1 here and below
        require(!isFromFrozen);

        bool isToFrozen;
        (isToFrozen,) = dataStorage.getFrozenAccount(_to);
        require(!isToFrozen);
        
        return super._transfer(_from, _to, _value);
    }
}