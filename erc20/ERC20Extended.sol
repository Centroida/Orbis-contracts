pragma solidity ^0.4.18;

import './extensions/FreezableToken.sol';
import './extensions/PausableToken.sol';
import './extensions/BurnableToken.sol';
import './extensions/MintableToken.sol';
import '../common/Destroyable.sol';

/**
 * @title ERC20Extended
 * @dev Standard ERC20 token with extended functionalities.
 */
contract ERC20Extended is FreezableToken, PausableToken, BurnableToken, MintableToken, Destroyable {
    string private constant NAME = "Example Name";

    string private constant SYMBOL = "EX";

    uint8 private constant DECIMALS = 18;

    /**
    * @dev The price at which the token is sold.
    */
    uint256 private sellPrice;

    /**
    * @dev the price at which the token is bought.
    */
    uint256 private buyPrice;

    address private wallet;

    /**
    * @dev Constructor function that calculates the total supply of tokens, 
    * sets the initial sell and buy prices and
    * passes arguments to base constructors.
    * @param _dataStorageAddress Address of the Data Storage Contract.
    * @param _ledgerAddress Address of the Data Storage Contract.
    * @param _initialSellPrice Sets the initial sell price of the token.
    * @param _initialBuyPrice Sets the initial buy price of the token.
    * @param _walletAddress Sets the address of the wallet of the contract.
    */
    function ERC20Extended(address _dataStorageAddress,
        address _ledgerAddress,
        uint256 _initialSellPrice,
        uint256 _initialBuyPrice,
        address _walletAddress) 
        FreezableToken(_dataStorageAddress, _ledgerAddress) 
        PausableToken(_dataStorageAddress, _ledgerAddress) 
        BurnableToken(_dataStorageAddress, _ledgerAddress) 
        MintableToken(_dataStorageAddress, _ledgerAddress) 
        public {
        sellPrice = _initialSellPrice;
        buyPrice = _initialBuyPrice;
        wallet = _walletAddress;
    }

    /**
    * @dev Fallback function that allows the contract
    * to recieve Ether directly.
    */
    function() payable public { }

    /**
    * @dev Function that returns the name of the token.
    * @return The name of the token.
    */
    function name() public pure returns (string) {
        return NAME;
    }

    /**
    * @dev Function that returns the symbol of the token.
    * @return The symbol of the token.
    */
    function symbol() public pure returns (string) {
        return SYMBOL;
    }

    /**
    * @dev Function that returns the number of decimals of the token.
    * @return The number of decimals of the token.
    */
    function decimals() public pure returns (uint8) {
        return DECIMALS;
    }

    /**
    * @dev Function that gets the sell price of the token.
    * @return The sell price of the token.
    */
    function getSellPrice() public view returns (uint256) {
        return sellPrice;
    }

    /**
    * @dev Function that gets the buy price of the token.
    * @return The buy price of the token.
    */
    function getBuyPrice() public view returns (uint256) {
        return buyPrice;
    }

    /**
    * @dev Function that sets both the sell and the buy price of the token.
    * @param _sellPrice The price at which the token will be sold.
    * @param _buyPrice The price at which the token will be bought.
    * @return success True on operation completion.
    */
    function setPrices(uint256 _sellPrice, uint256 _buyPrice) public onlyOwners returns (bool success) {
        sellPrice = _sellPrice;
        buyPrice = _buyPrice;
        return true;
    }

    /**
    * @dev Function that gets the current wallet address.
    * @return Address of the wallet.
    */
    function getWallet() public view returns (address) {
        return wallet;
    }

    /**
    * @dev Function that sets the current wallet address.
    * @param _walletAddress The address of wallet to be set.
    * @return success True on operation completion, or throws.
    */
    function setWallet(address _walletAddress) public onlyOwners returns (bool success) {
        require(_walletAddress != address(0));
        wallet = _walletAddress;
        return true;
    }

    /**
    * @dev Send Ether to buy tokens at the current token sell price.
    * @notice Throws on failure.
    */
    function buy() payable whenNotPaused public {
        uint256 amount = msg.value.div(sellPrice);
        _transfer(this, msg.sender, amount);
    }
    
    /**
    * @dev Sell `_amount` tokens at the current buy price.
    * @param _amount The amount to sell.
    * @notice Throws on failure.
    */
    function sell(uint256 _amount) whenNotPaused public {
        uint256 toBeTransferred = _amount.mul(buyPrice);
        require(this.balance >= toBeTransferred);
        require(_transfer(msg.sender, this, _amount));
        msg.sender.transfer(toBeTransferred);
    }

    /**
    * @dev Get the contract balance in WEI.
    */
    function getContractBalance() public view returns (uint256) {
        return this.balance;
    }

    /**
    * @dev Withdraw `_amount` ETH to the wallet address.
    * @param _amount The amount to withdraw.
    * @return success True on operation completion, or throws.
    */
    function withdraw(uint256 _amount) onlyOwners public returns (bool success) {
        require(this.balance >= _amount);
        wallet.transfer(_amount);
        return true;
    }
}
