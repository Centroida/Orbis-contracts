pragma solidity ^0.4.18;

import '../../modifiers/FromContract.sol';
import '../../common/SafeMath.sol';

contract LedgerData is FromContract {

    using SafeMath for uint256;

    struct Transaction {
        uint id;
        address from;
        address to;
        uint tokens;
    }

    mapping(uint => Transaction) private transactions;
    uint private transactionsLength = 0;

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

    function setTransactionsLength(uint _value) internal returns (bool) {
        transactionsLength = _value;
        return true;
    }
}