import BigInt

extension StringProtocol {
  fileprivate func dropHexPrefix() -> Self.SubSequence {
    self.hasPrefix("0x") ? self.dropFirst(2) : self.dropFirst(0)
  }
}

public protocol ExpressibleByPrefixedHexString {
  init?<S: StringProtocol>(hex: S)
}

extension Collection where Element: StringProtocol {
  public func cast<S: ExpressibleByPrefixedHexString>(to: S.Type) -> [S] {
    compactMap(S.init)
  }
}

extension UInt: ExpressibleByPrefixedHexString {
  public init?<S: StringProtocol>(hex: S) {
    self.init(hex.dropHexPrefix(), radix: 16)
  }
}

extension Int: ExpressibleByPrefixedHexString {
  public init?<S: StringProtocol>(hex: S) {
    self.init(hex.dropHexPrefix(), radix: 16)
  }
}

import Wei
extension Wei: ExpressibleByPrefixedHexString {
  public init?<S>(hex: S) where S: StringProtocol {
    self = hex(as: .wei)
  }
}
