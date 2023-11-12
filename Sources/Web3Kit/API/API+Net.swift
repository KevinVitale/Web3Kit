extension JSONRPC.Request where API == Net {
  public static func listening(requestId: Int = 1) -> JSONRPC.Request<API, Bool> {
    .init("listening", id: requestId)
  }
  
  public static func peerCount(requestId: Int = 1) -> JSONRPC.Request<API, String> {
    .init("peerCount", id: requestId)
  }
  
  public static func version(requestId: Int = 1) -> JSONRPC.Request<API, String> {
    .init("version", id: requestId)
  }
}
