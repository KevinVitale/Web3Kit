import AnyCodable

extension JSONRPC {
  /** TODO: Incomplete */
  public struct Error: Equatable, Decodable, Swift.Error {
    public let code    :AnyDecodable
    public let data    :AnyDecodable?
    public let message :String
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
      lhs.code == rhs.code
    }
  }
}
