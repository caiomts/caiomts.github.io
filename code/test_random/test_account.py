import random

from account_model import Account

def test_balance_account_increases_when_receive_a_transaction():
    account = Account(balance=2)   #(1)
    balance = account.balance    
    transaction = random.uniform(0, 1_000)  #(2)
    account.receive_transaction(transaction)     

    assert account.balance == balance + transaction


def test_balance_account_increases_when_receive_a_transaction_assert_4():
    account = Account(balance=2)
    balance = account.balance    
    transaction = 2
    account.receive_amount(transaction)     

    assert account.balance == 4