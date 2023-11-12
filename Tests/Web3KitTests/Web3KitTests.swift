import XCTest
import Web3Kit
import AnyCodable
import Wei

// Conveniences for creating new clients --------------------------------------
extension Client.Configuration {
  static let localNode: Self = "http://192.168.1.74:8545"
  static let localHost: Self = "http://127.0.0.1:8545"
}

final class EthTests: XCTestCase {
  let web3 = Web3Client(.localHost)
  var accounts: [String] = []
  
  var account: String {
    self.accounts.first ?? ""
  }
  
  override func setUp() async throws {
    self.accounts = try await web3.eth(request: .accounts()).result ?? []
  }
  
  func testSyncing() async throws {
    let syncing = try await web3.eth(request: .syncing()).result ?? false
    print(syncing)
  }
  
  func testCoinbase() async throws {
    let web3 = Web3Client(.localNode)
    do {
      let coinbase = try await web3.eth(request: .coinbase()).result ?? ""
      print(coinbase)
    } catch let error as JSONRPC.Error {
      print("Error:", error.message)
    }
  }
  
  func testChainId() async throws {
    let chainId = try await web3.eth(request: .chainId()).result ?? ""
    print(chainId)
  }
  
  func testMining() async throws {
    do {
      let mining = try await web3.eth(request: .mining()).result ?? false
      print(mining)
    } catch let error as JSONRPC.Error {
      print("Error:", error.message)
    }
  }
  
  func testHashrate() async throws {
    let hashrate = try await web3.eth(request: .hashrate()).result ?? ""
    print(hashrate)
  }
  
  func testGasPrice() async throws {
    let gasPrice = try await web3.eth(request: .gasPrice()).result ?? ""
    print(gasPrice)
  }
  
  func testAccounts() async throws {
    let accounts = try await web3.eth(request: .accounts()).result ?? []
    print(try accounts.prettyPrinted())
  }
  
  func testBlock() async throws {
    let balance = try await web3.eth(request: .block()).result ?? [:]
    print(try! balance.prettyPrinted())
  }
  
  func testBalanceForAddress() async throws {
    let balance = try await web3.eth(request: .balance(for: account)).result ?? ""
    print(balance(as: .wei).to(.ether))
  }
  
  func testStorageForAddress() async throws {
    XCTFail("Not yet implemented: \(#function)")
  }
  
  func testTransactionCountForAccount() async throws {
    let count = try await web3.eth(request: .transactionCount(for: account)).result ?? ""
    print(count)
  }
  
  func testTransactionCountByNumber() async throws {
    let count = try await web3.eth(request: .transactionCount(at: .earliest)).result ?? ""
    print(count)
  }
  
  func testUncleCount() async throws {
    let count = try await web3.eth(request: .uncleCount()).result ?? ""
    print(count)
  }
  
  func testCode() async throws {
    let web3 = Web3Client(.localNode)
    let usdc = "0xa2327a938Febf5FEC13baCFb16Ae10EcBc4cbDCF"
    let code = try await web3.eth(request: .code(for: usdc)).result ?? ""
    print(code)
  }
  
  func testSignMessage() async throws {
    let signature = try await web3.eth(request: .signMessage("0xdeadbeef", for: account)).result ?? ""
    print(signature)
  }
  
  func testSignAndSendRawTransaction() async throws {
  }
  
  func testTransactionByHash() async throws {
    let block = try await web3.eth(request: .block()).result ?? [:]
    let txHash = (block["transactions"]?.value as? [String] ?? []).first ?? ""
    let txByHash = try await web3.eth(request: .transaction(by: txHash)).value as! NSDictionary
    print(txByHash)
  }
  
  func testBlockAndTransactions() async throws {
    let block = try await web3.eth(request: .block()).result ?? [:]
    print(try block.prettyPrinted())
    
    let txHash = (block["transactions"]?.value as? [String] ?? []).first ?? ""
    let txByHash = try await web3.eth(request: "getTransactionByHash", parameters: [txHash]).value as? [String:Any]
    print((txByHash as? NSDictionary)!)
    
    let blockHash = txByHash?["blockHash"] as? String ?? ""
    let index = txByHash?["transactionIndex"] as? String ?? ""
    let blockByHash = try await web3.eth(request: "getTransactionByBlockHashAndIndex", parameters: [blockHash, index]).value as? [String:Any]
    print((blockByHash as? NSDictionary)!)
  }
  
  func testSendTransaction() async throws {
    let transaction = [
      "to": account,
      "from": account,
      "value": 1(as: .ether).hexString
    ]
    let result = try await web3.eth(request: "sendTransaction", parameters: [transaction]).result?.value as? String ?? ""
    print(result)
  }
  
  func testBatchRequests() async throws {
    let responses = try await web3.eth(request: "syncing", "accounts", "blockNumber")
    try responses.throw()
    try responses.results
      .forEach({ print(try $0.prettyPrinted()) })
  }
  
  func testMultipleBlocks() async throws {
    try await web3.eth(request:
      .block(.latest, requestId: 1),
      .block(.earliest, requestId: 2),
      .block(.pending, requestId: 3),
      .block(.number(1), requestId: 4)
    ).results.forEach({
      print(try $0.prettyPrinted())
    })
  }
}
