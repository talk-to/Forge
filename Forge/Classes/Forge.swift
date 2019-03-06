
import Result

public enum ForgeError: Error {
  case typeRegisteredAlready
  case typeNotFound
}

public final class Forge {

  /// Is used for persistence name so that multiple instances do not end up using
  /// same persistence layer.
  let UUID: String
  let persistor: Persistor
  let executionManager: ExecutionManager
  let taskRetrier: TaskRetrier

  public init(with UUID: String) {
    self.UUID = UUID
    self.persistor = Persistor(UUID: UUID)
    self.persistor.markAllTasksReadyToExecute()
    self.executionManager = ExecutionManager()
    self.executionManager.executionDelegate = self.persistor
    self.taskRetrier = TaskRetrier(executionManager: self.executionManager, persistor: self.persistor)
    self.taskRetrier.startRetrialForTasks()
    ForgeViewer.addToInstances(anObject: self)
    print("FORGEOBJECT: ", UUID)
  }

  public weak var changeManager: ChangeManager? {
    get {
      return executionManager.changeManager
    }
    set {
      executionManager.changeManager = newValue
    }
  }

  public func submit(task: Task, initialDelay: Int) {
    let pTask = PersistentTask(task: task, initialDelay: initialDelay)
    persistor.save(pTask: pTask)
    executionManager.changeManager?.willStart(task: pTask.task)
  }

  public func register(executor: Executor, for type: String) throws {
    try executionManager.register(executor: executor, for: type)
    for pTask in persistor.tasks(ofType: type) {
      executionManager.execute(task: pTask)
    }
  }

  public func undoTask(id: String) {
    guard let pTask = persistor.undoableTask(withID: id) else { return }
    executionManager.changeManager?.didComplete(task: pTask.task, result: Result.failure(ExecutorError.Cancelled))
    persistor.delete(id: id)
  }
}
