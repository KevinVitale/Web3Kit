extension JSONRPC.Request where API == Web3 {
  public static func clientVersion(requestId: Int = 1) -> JSONRPC.Request<API, String> {
    .init("clientVersion", id: requestId)
  }
  
  public static func sha3(data: String, requestId: Int = 1) -> JSONRPC.Request<API, String> {
    .init("sha3", parameters: [data], id: requestId)
  }
}
