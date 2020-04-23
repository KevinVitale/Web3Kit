import XCTest
import Web3Kit
import AnyCodable
import Wei

// Conveniences for creating new clients --------------------------------------
extension ClientConfiguration {
    static let localNode  :ClientConfiguration = "http://192.168.1.111:8545"
    static let localHost  :ClientConfiguration = "http://127.0.0.1:8545"
}

final class Web3KitTests: XCTestCase {
    func testProtocolVersion() throws {
        let web3 = Client<Web3>(.localHost)
        
        let version = try web3.eth(request: .protocolVersion()).hex(to: Int.self).get()
        print(version)
    }
    
    func testBlockNumbers() throws {
        let web3 = Client<Web3>(.localNode)
        
        let blocks = web3
            .eth(request:
                .block(.latest,    id: 1), // current block
                .block(.earliest,  id: 2), // genesis block
                .block(.pending,   id: 3), // pending block
                .block(.number(1), id: 4)  // certain block
            )
            .cast(to: [String:Any].self)
            .map({ $0.enumerated() })

        switch blocks {
        case .success(let responses):
            responses
                .map({ ($0.offset, $0.element) })
                .forEach({
                    // request id
                    print($0.0 + 1)
                    
                    // key-value
                    $0.1.forEach({ print($0) })
                })

        case .failure(let error as JSONRPCError):
            print(error)
            
        default:
            (/* no-op */)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func testGetBalances() throws {
        let web3 = Client<Web3>(.localHost)

        let block = try web3
            .eth(request: .block(.latest, fullResponse: false))
            .cast(to: [String:Any].self).get()!
        
        print(Int(hex: (block["number"] as! String))!)
        print((block["gasUsed"] as? String)!(as: .gas))
        
        let tx = (block["transactions"] as? [String]) ?? []
        print(tx.count)
    }
    
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
            result
                .enumerated()
                .forEach({ print($0) })
        case .failure(let error as JSONRPCError):
            print(error.message)
        default: ()
        }
    }

    func testSignTransactions() throws {
        let web3 = Client<Web3>(.localHost)
        switch web3.eth(request: .sign(address: "0x3e07d9AE4662CA5A541746Be369354DDAE09903C",
                                       message: "hello world"))
        {
        case .success(let response):
            print(response)
        case .failure(let error):
            print(error)
        }
    }
}
