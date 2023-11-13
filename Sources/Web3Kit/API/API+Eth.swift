import AnyCodable

extension JSONRPC.Request where API == Eth {
  public static func syncing(requestId: Int = 1) -> JSONRPC.Request<API, Bool> {
    .init("syncing", id: requestId)
  }
  
  public static func coinbase(requestId: Int = 1)  -> JSONRPC.Request<API, String> {
    .init("coinbase", id: requestId)
  }
  
  public static func chainId(requestId: Int = 1) -> JSONRPC.Request<API, String> {
    .init("chainId", id: requestId)
  }
  
  public static func mining(requestId: Int = 1) -> JSONRPC.Request<API, Bool> {
    .init("mining", id: requestId)
  }
  
  public static func hashrate(requestId: Int = 1) -> JSONRPC.Request<API, String> {
    .init("hashrate", id: requestId)
  }
  
  public static func gasPrice(requestId: Int = 1) -> JSONRPC.Request<API, String> {
    .init("gasPrice", id: requestId)
  }
  
  public static func accounts(requestId: Int = 1) -> JSONRPC.Request<API, [String]> {
    .init("accounts", id: requestId)
  }
  
  public static func block(_ block: BlockParameter = .latest, fullResponse: Bool = false, requestId: Int = 1) -> JSONRPC.Request<API, [String:AnyCodable]> {
    switch block {
      case .hash:
        return .init("getBlockByHash", parameters: [block.rawValue, fullResponse], id: requestId)
      default:
        return .init("getBlockByNumber", parameters: [block.rawValue, fullResponse], id: requestId)
    }
  }
  
  public static func balance(for account: String, at block: BlockParameter = .latest, requestId: Int = 1)  -> JSONRPC.Request<API, String> {
    .init("getBalance", parameters: [account, block.rawValue], id: requestId)
  }
  
  public static func storage(for address: String, in position: UInt, at block: BlockParameter = .latest, requestId: Int = 1)  -> JSONRPC.Request<API, String> {
    fatalError("See: https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_getstorageat")
  }
  
  public static func transactionCount(for account: String, at block: BlockParameter = .latest, requestId: Int = 1)  -> JSONRPC.Request<API, String> {
    .init("getTransactionCount", parameters: [account, block.rawValue], id: requestId)
  }
  
  public static func transactionCount(at block: BlockParameter = .latest, requestId: Int = 1)  -> JSONRPC.Request<API, String> {
    switch block {
      case .hash:
        return .init("getBlockTransactionCountByHash", parameters: [block.rawValue], id: requestId)
      default:
        return .init("getBlockTransactionCountByNumber", parameters: [block.rawValue], id: requestId)
    }
  }
  
  public static func uncleCount(at block: BlockParameter = .latest, requestId: Int = 1)  -> JSONRPC.Request<API, String> {
    switch block {
      case .hash:
        return .init("getUncleCountByBlockHash", parameters: [block.rawValue], id: requestId)
      default:
        return .init("getUncleCountByBlockNumber", parameters: [block.rawValue], id: requestId)
    }
  }
  
  public static func code(for address: String, at block: BlockParameter = .latest, requestId: Int = 1) -> JSONRPC.Request<API, String> {
    .init("getCode", parameters: [address, block.rawValue], id: requestId)
  }
  
  public static func signMessage(_ message: String, for address: String, requestId: Int = 1)  -> JSONRPC.Request<API, String> {
    .init("sign", parameters: [address, message], id: requestId)
  }
  
  public static func sendRawTransaction(_ transaction: String, requestId: Int = 1)  -> JSONRPC.Request<API, String> {
    .init("sendRawTransaction", parameters: [transaction], id: requestId)
  }
  
  public static func transaction(by hash: String, requestId: Int = 1) -> JSONRPC.Request<API, AnyCodable> {
    .init("getTransactionByHash", parameters: [hash], id: requestId)
  }
}

extension Client.Connection where API == Eth {
  public func balance(for accounts: String...) async throws -> [(String, JSONRPC.Response<String>)] {
    let requests = accounts.enumerated().map({ (offset, element) in JSONRPC.Request<Eth, String>.balance(for: element, requestId: offset) })
    return Array(zip(accounts, try await self(request: requests)))
  }
  
  public func balance(for accounts: [String]? = nil) async throws -> [(String, JSONRPC.Response<String>)] {
    var accounts = accounts
    if accounts == nil {
      accounts = try await (self(request: .accounts()).result ?? [])
    }
    let requests = accounts?.enumerated().map({ (offset, element) in JSONRPC.Request<Eth, String>.balance(for: element, requestId: offset) }) ?? []
    return Array(zip(accounts ?? [], try await self(request: requests)))
  }
}

extension Client.Connection where API == Eth {
  public func block(_ blocks: BlockParameter..., fullResponse: Bool = false) async throws -> [(BlockParameter, JSONRPC.Response<[String:AnyCodable]>)] {
    let requests = blocks.enumerated().map({ (offset, element) in JSONRPC.Request<Eth, String>.block(element, fullResponse: fullResponse, requestId: offset) })
    return Array(zip(blocks, try await self(request: requests)))
  }
  
  public func block(_ blocks: [BlockParameter], fullResponse: Bool = false) async throws -> [(BlockParameter, JSONRPC.Response<[String:AnyCodable]>)] {
    let requests = blocks.enumerated().map({ (offset, element) in JSONRPC.Request<Eth, String>.block(element, fullResponse: fullResponse, requestId: offset) })
    return Array(zip(blocks, try await self(request: requests)))
  }
}
