
import Result

public class Forge {

  /// Is used for persistence name so that multiple instances do not end up using
  /// same persistence layer.
  let UUID: String

  public init(with UUID: String) {
    self.UUID = UUID
  }

  public weak var changeManager: ChangeManager?

  public func submit(task: Task) {

  }

  public func register(executor: Executor, for type: IDType) {

  }
}

extension Forge: ExecutorCallbacks {

}
