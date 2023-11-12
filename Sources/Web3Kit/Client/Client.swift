public enum Client { }

public func Web3Client(_ configuration: Client.Configuration) -> Client.Connection<Web3> {
  .init(configuration)
}
