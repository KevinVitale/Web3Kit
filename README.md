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

### Example: Requests

A goal for `Web3Kit` was to be small, yet flexible and expressive. 

For any request you want to make, call `(request:parameters:)` with a string literal:

```swift
// Create a client
let web3 = Web3Client("127.0.0.1:8545")

// Calls 'web3_sha3'
let result = try await web3(request: "sha3", parameters: ["0xdeadbeef").result
print(result ?? "")
```

For convenience, most requests have statically defined equivalents:

```swift
// Create a client
let web3 = Web3Client("127.0.0.1:8545")

// Calls 'web3_sha3'
let result = try await web3(request: .sha(data: "0xdeadbeef")).result
print(result ?? "")
```

### Example: Checking balances

This example checks the balances of all the accounts on the node. It also demonstrates how
my micro-framework, [Wei](https://github.com/KevinVitale/Wei) can be used to convert `String`
values:

```swift
// Create a client
let web3 = Web3Client("127.0.0.1:8545")

// Use `.eth' to invoke domain-specific API requests
let balance = web3.eth(request: "getBalance", parameters: ["0x0000000000000000000000000000000000000000"]).result ?? ""

// Print the amount in ETHER
print(balance(as: .wei).to(.ether))
```


## Related Projects

`Web3Kit` is part of a suite of _Ethereum_ tools and frameworks built for those who ❤️ Swift.

- [WalletKit](https://github.com/KevinVitale/WalletKit)
- [Wei](https://github.com/KevinVitale/Wei)
