# zero_user_gas_fee

Basically, there are 3 ways that make user costs the gas fee
1. Approve a smart contract to send a custom token
2. Transfer ERC20 token
3. Call a function of smart contract


How to resolve it:

- The transaction has to be executed by the contract owner, not the end user.


1. Approve() function:


2. Transfer() function:


3. Smart contract: