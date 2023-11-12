import Foundation

extension Encodable {
  public func prettyPrinted() throws -> String {
    let encoder = JSONEncoder(); encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(self)
    let prettyPrinted = String(data: data, encoding: .utf8) ?? ""
    return prettyPrinted
  }
}

extension JSONRPC.Response where T: Encodable {
  public func prettyPrinted() throws -> String? {
    let encoder = JSONEncoder(); encoder.outputFormatting = .prettyPrinted
    guard let result = self.result else {
      return nil
    }
    let data = try encoder.encode(result)
    let prettyPrinted = String(data: data, encoding: .utf8) ?? ""
    return prettyPrinted
  }
}
