
import Result

public enum ForgeError: Error {
  case typeRegisteredAlready
  case typeNotFound
}

public final class Forge {

  /// Is used for persistence name so that multiple instances do not end up using
  /// same persistence layer.
  let id: String
  let persistor: Persistor
  let executionManager: ExecutionManager
  let taskRetrier: TaskRetrier

  public init(with UUID: String) {
    self.id = UUID
    self.persistor = Persistor(UUID: UUID)
    self.persistor.markAllTasksReadyToExecute()
    self.executionManager = ExecutionManager()
    self.executionManager.executionDelegate = self.persistor
    self.taskRetrier = TaskRetrier(executionManager: self.executionManager, persistor: self.persistor)
    self.taskRetrier.startRetrialForTasks()
    ForgeViewer.addToInstances(anObject: self)
  }

  public weak var changeManager: ChangeManager? {
    get {
      return executionManager.changeManager
    }
    set {
      executionManager.changeManager = newValue
    }
  }

  public func submit(task: Task, afterDelay delay: TimeInterval? = nil) -> String {
    let taskID = UUID().uuidString
    let pTask = PersistentTask(task: task, afterDelay: delay ?? 0.0, taskID: taskID)
    persistor.save(pTask: pTask)
    executionManager.execute(task: pTask, delay: delay)
    return taskID
  }

  public func register(executor: Executor, for type: String) throws {
    try executionManager.register(executor: executor, for: type)
    persistor.tasks(ofType: type) { [weak self] pTasks in
      guard let self = self else { return }
      for pTask in pTasks {
        self.executionManager.execute(task: pTask)
      }
    }
  }

  public func undoTask(id: String) {
    persistor.undoableTask(withID: id) { [weak self] (pTask) in
      guard let self = self else { return }
      self.executionManager.undoChangeManagerAction(pTask: pTask)
      self.persistor.delete(id: id)
    }
  }
}
