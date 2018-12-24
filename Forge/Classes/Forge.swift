
import Result

public class Forge {

  /// Is used for persistence name so that multiple instances do not end up using
  /// same persistence layer.
  let UUID: String
  let persistor: Persistor

  public init(with UUID: String) {
    self.UUID = UUID
    self.persistor = Persistor(UUID: UUID)
  }

  public weak var changeManager: ChangeManager?

  public func submit(task: Task) {

  }

  public func register(executor: Executor, for type: IDType) {

  }
}

extension Forge: ExecutorCallbacks {

  public func didComplete(task: Task, with: Result<Bool, ExecutorError>) {
  }
}
