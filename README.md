# NFT Smart Contracts

Gas optimised NFT smart contracts.

## Development

NOTE: You can easily copy and paste the contract into your existing project.
To use this project, you must have [truffle](https://www.npmjs.com/package/truffle) installed globally on your machine.

```bash
$ git clone https://github.com/kodjunkie/nft-smart-contracts.git
$ cd nft-smart-contracts
$ cp .env.example .env
$ npm install
```

## Compiling the contracts

```bash
$ truffle compile
```

## Deployment

NOTE: If you intend to deploy directly via this project, you must follow the instructions below.

1. Edit `migrations/2_deploy_contracts.js` and remove/comment out redundant deployments.
2. Update `.env` with the relevant information and run

```bash
# deploy to truffle network
$ truffle migrate
# deploy to truffle network using third-party wallet via HDwallet
$ truffle migrate --network wallet
# deploy to truffle network using third-party wallet via Dashboard
$ truffle migrate --network dashboard
# deploy to rinkeby network via Infura
$ truffle migrate --network rinkeby
```

More deployment configurations can be added to the `networks` object in the `truffle-config.js` file.

## Tests

```bash
$ truffle develop
> test
```
