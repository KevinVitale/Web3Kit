public protocol API {
  static var prefix: String { get }
}

public enum Web3: API { public static var prefix = "web3" }
public enum Eth: API { public static var prefix = "eth" }
public enum Net: API { public static var prefix = "net" }
