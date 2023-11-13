import Foundation
import AnyCodable

public protocol JSONRPCResponse: Identifiable, Decodable {
  associatedtype DecodedType: Decodable, Equatable
  
  var jsonrpc: String { get }
  var result: DecodedType? { get }
  var error: JSONRPC.Error? { get }
}

extension JSONRPC {
  @dynamicMemberLookup
  public struct Response<T: Decodable>: JSONRPCResponse where T: Equatable {
    public typealias DecodedType = T
    
    private enum CodingKeys: String, CodingKey {
      case error
      case id
      case jsonrpc
      case result
    }
    
    public let error: Error?
    public let id: Int
    public let jsonrpc: String
    public let result: T?
    
    fileprivate init(error: Error?, id: Int, jsonrpc: String, result: T?) {
      self.error   = error
      self.id      = id
      self.jsonrpc = jsonrpc
      self.result  = result
    }
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.error    = try container.decodeIfPresent(Error.self, forKey: .error)
      self.id       = try container.decode(Int.self, forKey: .id)
      self.jsonrpc  = try container.decode(String.self, forKey: .jsonrpc)
      self.result   = try container.decodeIfPresent(T.self, forKey: .result)
    }
    
    public subscript<Value>(dynamicMember keyPath: KeyPath<T, Value>) -> Value? {
      self.result?[keyPath: keyPath]
    }
  }
}

extension Collection where Element: JSONRPCResponse {
  public var errors: [Element] {
    self.filter({ $0.error != nil })
  }
  
  public var results: [Element.DecodedType] {
    self.compactMap({ $0.result })
  }
  
  public func `throw`() throws {
    if let error = self.compactMap({ $0.error }).first {
      throw error
    }
  }
}
