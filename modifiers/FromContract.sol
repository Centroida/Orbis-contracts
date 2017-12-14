pragma solidity ^0.4.18;

import './Ownable.sol';

/**
 * @title FromContract
 * @dev Base contract which allows calling members only from a specific external contract.
 */
 contract FromContract is Ownable {

  address public contractAddress;

  /**
   * @dev modifier that throws if the call is not from the specified contract.
   */
  modifier fromContract() {
    require(msg.sender == contractAddress);
    _;
  }

  /**
   * @dev allows the owner of the contract to set the contract address.
   * @param _newContractAddress The address to transfer current permission to.
   * @return True, if the operation has passed, or throws if failed.
   */
  function setContractAddress(address _newContractAddress) public onlyOwners returns (bool success) {
      require(_newContractAddress != address(0));
      contractAddress = _newContractAddress;
      return true;
  }
}