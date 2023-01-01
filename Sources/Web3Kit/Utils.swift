import Foundation

/* TODO: make 'internal' */
public func waitFor<T,ErrorType>(_ body: (@escaping (Result<T,ErrorType>) -> Void) -> Void) -> Result<T,Swift.Error> {
    Result { try _await(body) }
}

extension StringProtocol {
    fileprivate func dropHexPrefix() -> Self.SubSequence {
        self.hasPrefix("0x") ? self.dropFirst(2) : self.dropFirst(0)
    }
}

// https://stackoverflow.com/a/46663290
extension Data {
    fileprivate init?<S: StringProtocol>(hexString: S) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
}

public enum BlockParameter: RawRepresentable {
    /// Earliest/genesis block
    case earliest
    
    /// Latest mined block
    case latest
    
    /// Pending state/transactions
    case pending
    
    /// Integer block number
    case number(Int)
    
    case hash(String)
    
    public var rawValue: String {
        switch self {
        case .earliest  :return "earliest"
        case .latest    :return "latest"
        case .pending   :return "pending"
        case .number(let number) :return "0x" + String(number, radix: 16, uppercase: false)
        case .hash(let string)   :return string
        }
    }
    
    public init?(rawValue: String) {
        guard let block = BlockParameter(hex: rawValue) else {
            switch rawValue {
            case "earliest" :self = .earliest
            case "latest"   :self = .latest
            case "pending"  :self = .pending
            default         :return nil
            }
            return nil
        }
        
        self = block
    }
    
    /**
     FIXME: Figure 'number' vs. 'hash'
     */
    public init?<S>(hex: S) where S: StringProtocol {
        guard let number = Int(hex: hex) else {
            return nil
        }
        self = .number(number)
    }
}

import BigInt
public protocol ExpressibleByPrefixedHexString {
    init?<S: StringProtocol>(hex: S)
}

extension Collection where Element: StringProtocol {
    public func cast<S: ExpressibleByPrefixedHexString>(to: S.Type) -> [S] {
        compactMap(S.init)
    }
}

extension BInt: ExpressibleByPrefixedHexString {
    public init?<S: StringProtocol>(hex: S) {
      self.init(String(hex.dropHexPrefix()), radix: 16)
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
