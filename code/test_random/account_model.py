from pathlib import Path

class Account:
    """Account implementation."""

    def __init__(self, balance) -> None:
        self.balance = balance

    def receive_transaction(self, amount: float) -> None:
        """Update self.balance given the amount."""
        self.balance += amount  