
import Result

public class Forge {

  /// Is used for persistence name so that multiple instances do not end up using
  /// same persistence layer.
  let UUID: String
  let persistor: Persistor
  let executorsManager: ExecutorManager

  public init(with UUID: String) {
    self.UUID = UUID
    self.persistor = Persistor(UUID: UUID)
    self.executorsManager = ExecutorManager()
  }

  public weak var changeManager: ChangeManager? {
    get {
      return executorsManager.changeManager
    }
    set {
      executorsManager.changeManager = newValue
    }
  }

  public func submit(task: Task) {
    let pTask = PersistentTask(task: task)
    persistor.save(task: pTask)
    executorsManager.execute(task: pTask)
  }

  public func register(executor: Executor, for type: String) {
    executorsManager.register(executor: executor, for: type)
    for pTask in persistor.tasks(ofType: type) {
      executorsManager.execute(task: pTask)
    }
  }
}
