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
