pragma solidity ^0.4.18;

import "./ERC20StandardData.sol";

/**
 * @title ERC20ExtendedData
 * @dev Contract that manages the data for ERC20Extended contract and allows modifying data only from it.
 */
contract ERC20ExtendedData is ERC20StandardData {
    mapping(address => bool) private frozenAccounts;

    function getFrozenAccount(address _target) public view returns (bool isFrozen, uint256 amount) { /* AUDIT:  There might be a case for returning only if the account is frozen (thus might need renaming)
                                                                                                                as there is other constant methods that will return the balance if it is needed. 
                                                                                                                This will reduce the complexity in the imlementation */
        return (frozenAccounts[_target], balances[_target]);
    }

    function setFrozenAccount(address _target, bool _isFrozen) external fromContract returns (bool success, uint256 amount) {
        frozenAccounts[_target] = _isFrozen;
        return (true, balances[_target]);
    }
}