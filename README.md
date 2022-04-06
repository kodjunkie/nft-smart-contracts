# NFT Smart Contracts

Gas optimised NFT smart contracts.

## Development

You can easily copy and paste the contract into your existing project or to use this project, you must have [truffle](https://www.npmjs.com/package/truffle) installed globally on your machine.

```bash
$ git clone https://github.com/kodjunkie/nft-smart-contracts.git
$ cd nft-smart-contracts
$ cp .env.example .env
$ npm install
```

## Compiling the contracts

All compiled artifacts are located in the `builds` directory.

```bash
$ truffle compile
```

## Deployment

NOTE: If you intend to deploy directly via this project, you must follow the instructions below.

1. Edit `migrations/2_deploy_contracts.js` and remove/comment out redundant deployments.
2. Update `.env` accordingly and run any of the commands below

```bash
# deploy to truffle network
$ truffle migrate
# deploy to truffle network using third-party wallet via HDWalletProvider
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

## License

This project is opened under the <a href="https://github.com/kodjunkie/nft-smart-contracts/blob/master/LICENSE" target="_blank">MIT 2.0 License</a> which allows very broad use for both academic and commercial purposes.
