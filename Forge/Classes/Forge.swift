
import Result

public enum ForgeError: Error {
  case typeRegisteredAlready
  case typeNotFound
}

public enum LoggingSeverity {
  case Debug
  case Info
  case Verbose
  case Warn
  case Error
}

public protocol ForgeLogging {
  func debug(_ message: String, _ data: Any...)
  func info(_ message: String, _ data: Any...)
  func verbose(_ message: String, _ data: Any...)
  func warn(_ message: String, _ data: Any...)
  func error(_ message: String, _ data: Any...)
}

var logger: ForgeLogging?

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
    logger?.verbose("Forge instance initialised")
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
    logger?.verbose("Task submitted with generated id : \(taskID)")
    if delay != nil {
      logger?.verbose("Delay of \(delay) seconds")
    }
    let pTask = PersistentTask(task: task, afterDelay: delay ?? 0.0, taskID: taskID)
    persistor.save(pTask: pTask)
    logger?.verbose("Persistent task: \(pTask.uniqueID) saved in core data")
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
    logger?.verbose("Task with id : %@ requested to be reverted", id)
    persistor.undoableTask(withID: id) { [weak self] (pTask) in
      guard let self = self else { return }
      self.executionManager.undoChangeManagerAction(pTask: pTask)
      self.persistor.delete(id: id)
      logger?.verbose("Task %@ reverted", pTask)
    }
  }
}
