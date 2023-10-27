# For The Culture

This project is a simple NFT Omnichain to all remember the crypto culture and mostly SBF and FTX.

## Production Deployement

Base Address : [0xb1379c5041c5ca4c222388429ed5efa22c9bbde7](https://basescan.org/address/0xb1379c5041c5ca4c222388429ed5efa22c9bbde7)


## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Deploy

```shell
forge script script/Deploy.s.sol --broadcast --ledger --hd-paths HD_PATHS --legacy
--rpc-url https://goerli.base.org --sender ADDRESS_SENDER
```