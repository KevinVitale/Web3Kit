import AnyCodable

extension JSONRPC {
  public struct Request<API: Web3Kit.API, Response: Decodable>: Encodable, Identifiable, ExpressibleByStringLiteral {
    private enum CodingKeys: String, CodingKey {
      case id
      case method
      case jsonRPC = "jsonrpc"
      case parameters = "params"
    }
    
    public let id: Int
    public let method: String
    public let parameters: [Any]
    public var jsonRPC: String { JSONRPC.version }
    
    init(_ method: String, parameters params: [Any] = [], id: ID = 1) {
      self.id         = id
      self.method     = "\(API.prefix)_\(method)"
      self.parameters = params
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(id, forKey: .id)
      try container.encode(method, forKey: .method)
      try container.encode(jsonRPC, forKey: .jsonRPC)
      try container.encode(parameters.compactMap(AnyEncodable.init), forKey: .parameters)
    }
    
    public init(stringLiteral value: StringLiteralType) {
      self = Request(value, parameters: [AnyCodable]())
    }
  }
}
