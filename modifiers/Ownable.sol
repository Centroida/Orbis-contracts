pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract holds owner addresses, and provides basic authorization control
 * functions.
 */
contract Ownable {
  mapping(address => bool) private owners; 

  /**
   * @dev The Ownable constructor adds the sender
   * account to the owners mapping.
   */
  function Ownable() public {
    owners[msg.sender] = true;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwners() {
    require(owners[msg.sender] == true);
    _;
  }

  /**
   * @dev Allows the current owners to add new owner to the contract.
   * @param _newOwner The address to grant owner rights.
   * @return True if the operation has passed or throws if failed.
   */
  function addOwner(address _newOwner) public onlyOwners returns (bool success) {
    require(_newOwner != address(0));
    owners[_newOwner] = true;
    return true;
  }

  /**
   * @dev Allows the current owners to remove an existing owner from the contract.
   * @param _owner The address to revoke owner rights.
   * @return True if the operation has passed or false if failed.
   */
  function removeOwner(address _owner) public onlyOwners returns (bool success) {
    if (owners[_owner]) {
      owners[_owner] = false;
      return true;
    }
    return false;
  }

  /**
   * @dev Allows to check if the given address has owner rights.
   * @param _owner The address to check for owner rights.
   * @return True if the adress is owner, false if it is not.
   */
  function isOwner(address _owner) public view returns (bool) {
    return owners[_owner];
  }
}