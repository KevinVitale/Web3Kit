import Foundation
import BigInt
import AnyCodable

public protocol JSONAPIResponse: Identifiable, Decodable where R: Decodable {
    associatedtype R
    
    var error  :JSONRPCError? { get }
    var result :R? { get }
}

public extension JSONAPIResponse where R: Equatable {
    static func ==(lhs: Self, rhs: Self.R) -> Bool {
        lhs.result == rhs
    }
}

public struct Response<R: Decodable>: JSONAPIResponse, Equatable where R: Equatable {
    private enum CodingKeys: String, CodingKey {
        case error
        case id
        case jsonrpc
        case result
    }
    
    public let error   :JSONRPCError?
    public let id      :Int
    public let jsonrpc :String
    public let result  :R?

    fileprivate init(error: JSONRPCError?, id: ID, jsonrpc: String, result: R?) {
        self.error   = error
        self.id      = id
        self.jsonrpc = jsonrpc
        self.result  = result
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.error    = try container.decodeIfPresent(JSONRPCError.self, forKey: .error)
        self.id       = try container.decode(Int.self, forKey: .id)
        self.jsonrpc  = try container.decode(String.self, forKey: .jsonrpc)
        self.result   = try container.decodeIfPresent(R.self, forKey: .result)
    }
}

extension Result where Success: JSONAPIResponse, Failure == Swift.Error, Success.R: StringProtocol {
    public func hex<S: ExpressibleByPrefixedHexString>(to: S.Type) -> Result<S, Failure> {
        self.flatMap { response in
            guard response.error == nil else {
                return .failure(response.error!)
            }
            
            guard let hexString = response.result, let value = S(hex: hexString) else {
                return .failure(CocoaError(.coderInvalidValue))
            }
            
            return .success(value)
        }
    }
}

extension Result where Success: JSONAPIResponse, Failure == Swift.Error, Success.R == AnyDecodable {
    public func cast<S>(to: S.Type) -> Result<S?, Failure> {
        self.flatMap { response in
            guard response.error == nil else {
                return .failure(response.error!)
            }

            return .success(response.result?.value as? S)
        }
    }
}

extension Result where Success: Collection, Success.Element: JSONAPIResponse, Failure == Swift.Error, Success.Element.R == AnyDecodable {
    public func hex<S: ExpressibleByPrefixedHexString>(to: S.Type) -> Result<[S], Failure> {
        self.map { response in
            response
                .compactMap { $0.result?.value as? String }
                .cast(to: S.self)
        }
    }
    
    public func cast<S>(to: S.Type) -> Result<[S], Failure> {
        self.map {
            $0.compactMap { $0.result?.value as? S }
        }
    }
}

extension Sequence where Element: JSONAPIResponse {
    public var result: [Element.R] {
        compactMap { $0.result }
    }
}

/*
extension Result where Success: JSONAPIResponse {
    public func result() throws -> Success.R? {
        try get().result
    }
}

extension Result where Success: Collection, Success.Element: JSONAPIResponse, Failure == Swift.Error {
    public func result() throws -> [Success.Element.R] {
        try get().result.compactMap { $0 }
    }
}
 */
