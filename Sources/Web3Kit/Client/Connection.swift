import Foundation
import AnyCodable

extension Client {
  public struct Connection<API: Web3Kit.API> {
    public typealias Request<T: Decodable> = JSONRPC.Request<API, T> where T: Equatable
    public typealias Response<T: Decodable> = JSONRPC.Response<T> where T: Equatable
    
    private let configuration: Configuration
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder = JSONDecoder()
    
    /**
     Creates the underlying `URLRequest` from `jsonRequest`.
     
     - parameter jsonRequest:
     - returns:
     */
    private func urlRequest<T: Encodable>(jsonRequest: T) -> URLRequest {
      var urlRequest = URLRequest(url: configuration.url)
      urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
      urlRequest.httpMethod  = "POST"
      urlRequest.httpBody = try? encoder.encode(jsonRequest)
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
      return urlRequest
    }
    
    /**
     Performs a JSON-RPC request using `jsonRequest`.
     
     - parameter jsonRequest:
     - returns:
     */
    private func request<T: Encodable, R: Decodable>(_ jsonRequest: T) async throws -> R {
      let urlRequest = urlRequest(jsonRequest: jsonRequest)
      let (data, _ /* urlResponse */) = try await session.data(for: urlRequest)
      let response = try decoder.decode(R.self, from: data)
      return response
    }
    
    /**
     - parameter method:
     - parameter parameters:
     - parameter requestId:
     - parameter resultType:
     
     - returns:
     */
    @discardableResult
    public func callAsFunction<T>(request method: String, parameters: [Any] = [], id requestId: Int = 1, resultType: T.Type = AnyDecodable.self) async throws -> Response<T> {
      let request = Request<T>(method, parameters: parameters, id: requestId)
      let response: Response<T> = try await self.request(request)
      
      // Check for (and throw) non-errors.
      if let error = response.error { throw error }
      
      return response
    }
    
    @discardableResult
    public func callAsFunction<T>(request: Request<T>) async throws -> Response<T> {
      let response: Response<T> = try await self.request(request)
      
      // Check for (and throw) non-errors.
      if let error = response.error { throw error }
      
      return response
    }
    
    @discardableResult
    public func callAsFunction<T>(request: Request<T>...) async throws -> [Response<T>] {
      let response: [Response<T>] = try await self.request(request)
      
      return response
    }
    
    @discardableResult
    public func callAsFunction(request: Request<AnyCodable>...) async throws -> [Response<AnyCodable>] {
      let response: [Response<AnyCodable>] = try await self.request(request)
      
      return response
    }
  }
}

extension Client.Connection<Web3> {
  public init(_ configuration: Client.Configuration, session: URLSession = URLSession(configuration: .default)) {
    self.configuration = configuration
    self.session = session
    self.encoder = JSONEncoder()
    self.encoder.outputFormatting = .prettyPrinted
  }
  
  func derivedClient<A: Web3Kit.API>() -> Client.Connection<A> {
    .init(configuration: self.configuration,
          session: self.session,
          encoder: self.encoder)
  }
  
  public var eth: Client.Connection<Eth> { derivedClient() }
  public var net: Client.Connection<Net> { derivedClient() }
}
