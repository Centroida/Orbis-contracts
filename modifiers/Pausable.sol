pragma solidity ^0.4.18;

import './Ownable.sol';

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();
  
  bool public paused = true;

  /**
   * @dev Modifier to allow actions only when the contract IS NOT paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to allow actions only when the contract IS paused.
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev Called by the owner to pause, triggers stopped state.
   * @return True if the operation has passed.
   */
  function pause() public onlyOwners returns (bool success) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev Called by the owner to unpause, returns to normal state.
   * @return True if the operation has passed.
   */
  function unpause() public onlyOwners returns (bool success) {
    paused = false;
    Unpause();
    return true;
  }
}