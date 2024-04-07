## With this basic understanding of how digital signatures work, we can now propose the following system of implementing allowlists

1. Create a centralized server and database that holds all the addresses that are allowlisted.
2. When a wallet tries to initiate a mint on your website, send the wallet address to your server.
3. The server checks if the address has been allowlisted and if it has, it signs the wallet address with a private key that is known only to the project’s creator.
4. The server returns the signed message to the frontend client (or website) and this in turn, is sent to the smart contract.
5. The contract’s mint function verifies that the message sent was indeed signed by the wallet controlled by the owner. If the verification succeeds, minting is allowed.
6. The signed message is stored in a mapping to prevent it from being used more than once or by multiple wallets.