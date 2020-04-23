<img src="Web3Kit.png" />

## Platforms
- **macOS**, v10.15+;
- **iOS**, v13+;
- **Linux**

## Adding `Web3Kit` as a Dependency
To use the `Web3Kit` library in a Swift Package Manager (SPM) project, add the following line to the _dependencies_ in you `Package.swift` file:
    
```swift
.package(url: "https://github.com/KevinVitale/Web3Kit", from: "0.0.1"),
```

The `Web3Kit` library is under active development, and while attempts are made to maintain source-stability, this is not guaranteed between minor versions. You may specify `.upToNextMinor(from:)`, instead of `from(_:)`, if you need to be at a specific version.

## Usage

A `Web3Kit` clients can work with any node source, such as:

- a local _Ganache_ node (even one running inside a **Docker** container);
- a local network _Geth_ node;
- an _Infura_ node!

All this makes testing on _macOS_, _iOS_, or _Linux_ really simple.

### Checking balances

This example checks the balances of all the accounts on the node. It also demonstrates how
my micro-framework, (Wei)[https://github.com/KevinVitale/Wei] can be used to convert `String`
values:

#### Code

```swift
func testAccountBalances() throws {
    let web3 = Client<Web3>(.localHost)

    let accounts = try web3
        .eth(request: .accounts())
        .get()
        .result ?? []

    let balances = try web3
        .eth(request: .getBalances(addresses: accounts))
        .hex(to: Wei.self)
        .get()

    balances
        .enumerated()
        .map({ (accounts[$0.offset], $0.element.to(.ether)) })
        .forEach {
            print($0)
    }
}
```
#### Output

```
("0x3e07d9ae4662ca5a541746be369354ddae09903c", 98.99958 ETHER)
("0x0cbe55df6ec0b2ad41274dad7ccf17fc632cf749", 101 ETHER)
("0x890d6c0fd57104f6e69e1d86cdf3837d7253ddeb", 100 ETHER)
("0x9d689e027d0eaf4dadd8e6a67c973f348c599b6d", 100 ETHER)
("0x0bb097317dec5fad0d6dc10e176a355ad37c7176", 100 ETHER)
("0x97e9e657277ed079369aa05b16f835b3be7db483", 100 ETHER)
("0x090d1168cf7aeafceb21c354a80db4e8634ad0fa", 100 ETHER)
("0x904df709eaaee61ad20a10fb7095a0d0a485f7e7", 100 ETHER)
("0xe4e5d6983b8b6d0aa7d4df0568a3a3770936fbdb", 100 ETHER)
("0x1fa2a2b2e63ee7c372b6fe8c7f04eccc3f3029cc", 100 ETHER)
```

### Transfering Ether

This example transfers 1 ETH to another account:

#### Code

```swift
func testSendTransaction() throws {
    let web3 = Client<Web3>(.localHost)
    let payload = [
        "to"    :"0x0cbe55df6ec0b2ad41274dad7ccf17fc632cf749",
        "from"  :"0x3e07d9AE4662CA5A541746Be369354DDAE09903C",
        "value" :1(as: .ether).hexString,
    ]
    
    let receipt = web3
        .eth(request: "sendTransaction", parameters: [payload], id: 1)
        .cast(to: String.self)
        .flatMap({
            txHash in web3.eth(request: "getTransactionReceipt", parameters: [txHash ?? ""])
        })
        .cast(to: [String:Any].self)
    
    switch receipt {
    case .success(let result?):
        print(result)
    case .failure(let error as JSONRPCError):
        print(error.message)
    default: ()
    }
}
```

#### Output

```
(offset: 0, element: (key: "cumulativeGasUsed", value: "0x5208"))
(offset: 1, element: (key: "contractAddress", value: <null>))
(offset: 2, element: (key: "logs", value: []))
(offset: 3, element: (key: "blockHash", value: "0xbbd0652363099586abda2830addf125e85aea711fb0328d93ab673860dc95583"))
(offset: 4, element: (key: "blockNumber", value: "0x3"))
(offset: 5, element: (key: "from", value: "0x3e07d9ae4662ca5a541746be369354ddae09903c"))
(offset: 6, element: (key: "transactionIndex", value: "0x0"))
(offset: 7, element: (key: "gasUsed", value: "0x5208"))
(offset: 8, element: (key: "status", value: "0x1"))
(offset: 9, element: (key: "logsBloom", value: "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"))
(offset: 10, element: (key: "transactionHash", value: "0xcb7a884177f19cfd43e0d92e6167c9b66deecae31ff3d106d7d2c96697f63ad9"))
(offset: 11, element: (key: "to", value: "0x0cbe55df6ec0b2ad41274dad7ccf17fc632cf749"))
```

## Related Projects

`Web3Kit` is part of a suite of _Ethereum_ tools and frameworks built for those who ❤️ Swift.

- (WalletKit)[https://github.com/KevinVitale/WalletKit]
- (Wei)[https://github.com/KevinVitale/Wei]
