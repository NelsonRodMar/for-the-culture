# For The Culture

This project is a simple NFT Omnichain to all remember the crypto culture and mostly SBF and FTX.

## Production Deployement

Base Address : [0xb1379c5041c5ca4c222388429ed5efa22c9bbde7](https://basescan.org/address/0xb1379c5041c5ca4c222388429ed5efa22c9bbde7)
Scroll Address : [0x3374Eb14b0293D51756f6865a7715D7699b53693](https://scrollscan.com/address/0x3374eb14b0293d51756f6865a7715d7699b53693)


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

## How to bridge using Explorer ?

### Bridge in a few steps

1. Go to the contract page see section on top

2. Click on `Contract` > `Write Contract` and find the function `sendFrom`

3. You first need to approve the contract to spend your token, so click on `approve` and fill the info like this :
   - `to` to (address) : The address of the contract
   - `tokenId` tokenId (uint256) : The token id to approve

4. Fill the different info like this :
   - `sendFrom` payableAmount (ether) : Either put an amount like 0.005 (don't worry you will be refund if you put more ETH than needed) or see bellow (**How to get perfect gas cost ?**) on how to get perfect gas cost
   - `_from`  _from (address) : The address of the receiver
   - `_dstChainId` _dstChainId (uint16) : The chain id of destination (Scroll : 214, Base : 184), or see LayerZero documentation [here](https://layerzero.gitbook.io/docs/technical-reference/mainnet/supported-chain-ids)
   - `_toAddress` _toAddress (bytes) : The address of the receiver on the destination chain
   - `_tokenId`_tokenId (uint256) : The id of the token to send 
   - `_refundAddress` _refundAddress (address) : The address to refund if the transaction fails 
   - `_zroPaymentAddress` _zroPaymentAddress (address) : Add this value `0x000000000000000000000000000000000000dEaD`
   - `_adapterParams` _adapterParams (bytes) : Add this value `0x00010000000000000000000000000000000000000000000000000000000000030d40` it's the adapter params to use for the bridge (see [here](https://layerzero.gitbook.io/docs/evm-guides/advanced/relayer-adapter-parameters) for more info)

5. Click on `Write` and confirm the transaction on your wallet. You can see the OFNT transfer on the explorer [here](https://layerzeroscan.com/) by putting the transaction hash.

### How to get perfect gas cost ?

1. Go to the contract page see section on top

2. Click on `Contract` > `Read Contract` and find the function `estimateSendFee` and complete with following info :
   - `_dstChainId` _dstChainId (uint16) : The chain id of destination (Scroll : 214, Base : 184), or see LayerZero documentation [here](https://layerzero.gitbook.io/docs/technical-reference/mainnet/supported-chain-ids)
   - `_toAddress` _toAddress (bytes) : The address of the receiver on the destination chain
   - `_tokenId`_tokenId (uint256) : The id of the token to send
   - `_useZro` _useZro (bool) : Add this value `false`
   - `_adapterParams` _adapterParams (bytes) : Add this value `0x00010000000000000000000000000000000000000000000000000000000000030d40` it's the adapter params to use for the bridge (see [here](https://layerzero.gitbook.io/docs/evm-guides/advanced/relayer-adapter-parameters) for more info)

3. You will get two result `nativeFee` and `zroFee`; you only need to take the `nativeFee` value.