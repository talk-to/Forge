
import Result

public enum ForgeError: Error {
  case typeRegisteredAlready
  case typeNotFound
}

public protocol ForgeLogging {
  func forgeDebug(_ message: String)
  func forgeInfo(_ message: String)
  func forgeVerbose(_ message: String)
  func forgeWarn(_ message: String)
  func forgeError(_ message: String)
}

private(set) var logger: ForgeLogging?

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
    logger?.forgeVerbose("Forge instance initialised")
  }
  
  public func setupLogging(with injectedLogger: ForgeLogging) {
    logger = injectedLogger
  }

  public weak var changeManager: ChangeManager? {
    get {
      return executionManager.changeManager
    }
    set {
      executionManager.changeManager = newValue
    }
  }

  @discardableResult public func submit(task: Task, afterDelay delay: TimeInterval? = nil) -> String {
    let taskID = PersistentTask.uniqueString()
    logger?.forgeVerbose("Task submitted with generated id : \(taskID)")
    if delay != nil {
      logger?.forgeVerbose("Delay of \(delay) seconds")
    }
    let pTask = PersistentTask(task: task, afterDelay: delay ?? 0.0, taskID: taskID)
    persistor.save(pTask: pTask)
    logger?.forgeVerbose("Persistent task: \(pTask) saved in core data")
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
    logger?.forgeVerbose("Task with id : \(id) requested to be reverted")
    persistor.undoableTask(withID: id) { [weak self] (pTask) in
      guard let self = self else { return }
      self.executionManager.undoChangeManagerAction(pTask: pTask)
      self.persistor.delete(id: id)
      logger?.forgeVerbose("Task \(pTask) reverted")
    }
  }
}
