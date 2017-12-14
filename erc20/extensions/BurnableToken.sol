pragma solidity ^0.4.18;

import '../ERC20Standard.sol';
import '../../modifiers/Ownable.sol';

/**
 * @title BurnableToken
 * @dev ERC20Standard token that can be irreversibly burned(destroyed).
 */
contract BurnableToken is ERC20Standard, Ownable {

    event Burn(address indexed _burner, uint256 _value);
    
    function BurnableToken(address _dataStorageAddress, address _ledgerAddress) ERC20Standard(_dataStorageAddress, _ledgerAddress) public {}

    /**
     * @dev Remove tokens from the system irreversibly.
     * @notice Destroy tokens from your account.
     * @param _value The amount of tokens to burn.
     */
    function burn(uint256 _value) public returns (bool success) {
        uint256 senderBalance = dataStorage.getBalance(msg.sender);
        require(senderBalance >= _value);
        senderBalance = senderBalance.sub(_value);
        require(dataStorage.setBalance(msg.sender, senderBalance));

        uint256 totalSupply = dataStorage.getTotalSupply();
        totalSupply = totalSupply.sub(_value);
        require(dataStorage.setTotalSupply(totalSupply));

        Burn(msg.sender, _value);

        return true;
    }

    /**
     * @dev Remove specified `_value` tokens from the system irreversibly on behalf of `_from`.
     * @param _from The address from which to burn tokens.
     * @param _value The amount of money to burn.
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        uint256 fromBalance = dataStorage.getBalance(_from);
        require(fromBalance >= _value);

        uint256 allowed = dataStorage.getAllowance(_from, msg.sender);
        require(allowed >= _value);

        fromBalance = fromBalance.sub(_value);
        require(dataStorage.setBalance(_from, fromBalance));

        allowed = allowed.sub(_value);
        require(dataStorage.setAllowance(_from, msg.sender, allowed));

        uint256 totalSupply = dataStorage.getTotalSupply();
        totalSupply = totalSupply.sub(_value);
        require(dataStorage.setTotalSupply(totalSupply));

        Burn(_from, _value);

        return true;
    }
}