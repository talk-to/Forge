
import Result

public enum ForgeError: Error {
  case typeRegisteredAlready
  case typeNotFound
}

public class Forge {

  /// Is used for persistence name so that multiple instances do not end up using
  /// same persistence layer.
  let UUID: String
  let persistor: Persistor
  let executionManager: ExecutionManager

  public init(with UUID: String) {
    self.UUID = UUID
    self.persistor = Persistor(UUID: UUID)
    self.persistor.markAllTasksReadyToExecute()
    self.executionManager = ExecutionManager()
    self.executionManager.executionDelegate = self.persistor
  }

  public weak var changeManager: ChangeManager? {
    get {
      return executionManager.changeManager
    }
    set {
      executionManager.changeManager = newValue
    }
  }

  public func submit(task: Task) {
    let pTask = PersistentTask(task: task)
    persistor.save(pTask: pTask)
    executionManager.execute(task: pTask)
  }

  public func register(executor: Executor, for type: String) throws {
    try executionManager.register(executor: executor, for: type)
    for pTask in persistor.tasks(ofType: type) {
      executionManager.execute(task: pTask)
    }
  }
}
