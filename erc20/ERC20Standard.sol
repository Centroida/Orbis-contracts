pragma solidity ^0.4.18;

import '../common/SafeMath.sol';

interface EternalDataStorage {
function getBalance(address _owner) public view returns (uint256);

function setBalance(address _owner, uint256 _value) external returns (bool success);

function getAllowance(address _owner, address _spender) public view returns (uint256);

function setAllowance(address _owner, address _spender, uint256 _amount) external returns (bool success);

function getTotalSupply() public view returns (uint256);

function setTotalSupply(uint256 _value) external returns (bool success);

function getFrozenAccount(address _target) public view returns (bool isFrozen, uint256 amountFrozen);

function setFrozenAccount(address _target, bool _isFrozen) external returns (bool success, uint256 amountFrozen);
}

interface Ledger {
    function addTransaction(address _from, address _to, uint _tokens) public returns (bool);
}


/**
 * @title ERC20Standard token
 * @dev Implementation of the basic standard token.
 * @notice https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract ERC20Standard {
    
    using SafeMath for uint256;

    EternalDataStorage internal dataStorage;

    Ledger internal ledger;

    /**
    * @dev Triggered when tokens are transferred.
    * @notice MUST trigger when tokens are transferred, including zero value transfers.
    */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /**
    * @dev Triggered whenever approve(address _spender, uint256 _value) is called.
    * @notice MUST trigger on any successful call to approve(address _spender, uint256 _value).
    */
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /**
    * @dev Constructor function that instantiates the EternalDataStorage and Ledger contracts.
    * @param _dataStorageAddress Address of the Data Storage Contract.
    * @param _ledgerAddress Address of the Data Storage Contract.
    */
    function ERC20Standard(address _dataStorageAddress, address _ledgerAddress) public {
        dataStorage = EternalDataStorage(_dataStorageAddress);
        ledger = Ledger(_ledgerAddress);
    }

    /**
    * @dev Gets the total supply of tokens.
    * @return totalSupplyAmount The total amount of tokens.
    */
    function totalSupply() public view returns (uint256 totalSupplyAmount) {
        return dataStorage.getTotalSupply();
    }

    /**
    * @dev Get the balance of the specified `_owner` address.
    * @return balance The token balance of the given address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return dataStorage.getBalance(_owner);
    }

    /**
    * @dev Transfer token to a specified address.
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    * @return success True if the transfer was successful, or throws.
    */
    function transfer(address _to, uint256 _value) public returns (bool success) { // AUDIT: In our case I would put requirement for greater than 0 value as someone might try to fill the ledger up with useless 0 value transactions
        return _transfer(msg.sender, _to, _value);
    }

    /**
     * @dev Transfer `_value` tokens to `_to` in behalf of `_from`.
     * @param _from The address of the sender.
     * @param _to The address of the recipient.
     * @param _value The amount to send.
     * @return success True if the transfer was successful, or throws.
     */    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) { // AUDIT: Same as above
        uint256 allowed = dataStorage.getAllowance(_from, msg.sender);
        require(allowed >= _value);

        allowed = allowed.sub(_value);
        require(dataStorage.setAllowance(_from, msg.sender, allowed));

        return _transfer(_from, _to, _value);
    }

    /**
     * @dev Allows `_spender` to withdraw from your account multiple times, up to the `_value` amount.
     * @notice If this function is called again it overwrites the current allowance with `_value`.
     * @param _spender The address authorized to spend.
     * @param _value The max amount they can spend.
     * @return success True if the operation was successful, or false.
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        if (dataStorage.setAllowance(msg.sender, _spender, _value)) {
            Approval(msg.sender, _spender, _value);
            return true;
        }

        return false;
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner The address which owns the funds.
    * @param _spender The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return dataStorage.getAllowance(_owner, _spender);
    }

    /**
    * @dev Internal transfer, can only be called by this contract.
    * @param _from The address of the sender.
    * @param _to The address of the recipient.
    * @param _value The amount to send.
    * @return success True if the transfer was successful, or throws.
    */
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
        require(_to != address(0));
        uint256 fromBalance = dataStorage.getBalance(_from);
        require(fromBalance >= _value);

        fromBalance = fromBalance.sub(_value);

        uint256 toBalance = dataStorage.getBalance(_to);
        toBalance = toBalance.add(_value);

        require(dataStorage.setBalance(_from, fromBalance));
        require(dataStorage.setBalance(_to, toBalance));

        require(ledger.addTransaction(_from, _to, _value));

        Transfer(_from, _to, _value);

        return true;
    }
}