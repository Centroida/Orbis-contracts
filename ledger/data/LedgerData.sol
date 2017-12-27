pragma solidity ^0.4.18;

import '../../modifiers/FromContract.sol';
import '../../common/SafeMath.sol';

contract LedgerData is FromContract {

    using SafeMath for uint256;

    struct Transaction {
        uint id; // AUDIT: Save storage space by not using this field as you already have this data in the key
        address from;
        address to;
        uint tokens; // AUDIT: Keep using uint256 as you've started with it in the ERC20 things
    }

    mapping(uint => Transaction) private transactions; // AUDIT: Make this public and you wont need the method for getting Transaction as it is auto generated

    uint private transactionsLength = 0; // AUDIT: Make this public and you wont need the method for getting transaction length as it is auto generated

    function getTransaction(uint _index) public view returns (uint, address, address, uint) {
        return (transactions[_index].id, transactions[_index].from, transactions[_index].to, transactions[_index].tokens);
    }

    function addTransaction(address _from, address _to, uint _tokens) external fromContract returns (bool) {
        var transaction = transactions[transactionsLength];
        transaction.id = transactionsLength;
        transaction.from = _from;
        transaction.to = _to;
        transaction.tokens = _tokens;
        setTransactionsLength(transactionsLength.add(1));
        return true;
    }

    function getTransactionsLength() public view returns (uint) {
        return transactionsLength;
    }

    function setTransactionsLength(uint _value) internal returns (bool) { // AUDIT: Making the transactionsLength public will render this method obsolete
        transactionsLength = _value;
        return true;
    }
}