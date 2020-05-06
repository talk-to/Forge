
import Foundation
import Result

class ExecutionManager {

  weak var executionDelegate: ExecutionDelegate?
  weak var changeManager: ChangeManager?

  private func _execute(task pTask: PersistentTask, executor: Executor) {
    changeManager?.willStart(task: pTask.task)
    executionDelegate?.start(pTask: pTask)
    executor.execute(task: pTask.task, countOfRetries: pTask.countOfRetries) { [weak self] result in
      guard let strongSelf = self else {
        fatalError("Execution manager deallocated!")
      }
      switch result {
      case .success(_):
        logger?.forgeInfo("Task \(pTask) successfully executed")
        strongSelf.executionDelegate?.delete(pTask: pTask)
        strongSelf.changeManager?.didComplete(task: pTask.task, result: result)
      case .failure(let error):
        switch error {
        case .NonRetriable(_):
          logger?.forgeWarn("Task \(pTask) failed to complete : Non Retriable")
          strongSelf.executionDelegate?.delete(pTask: pTask)
          strongSelf.changeManager?.didComplete(task: pTask.task, result: result)
        case .ConditionalRetriable:
          logger?.forgeWarn("Task \(pTask) failed to complete : Conditional Retriable")
          strongSelf.executionDelegate?.fail(pTask: pTask, increaseRetryCount: false)
          return
        case .NonConditionalRetriable:
          logger?.forgeWarn("Task \(pTask) failed to complete : Non Conditional Retriable")
          strongSelf.executionDelegate?.fail(pTask: pTask, increaseRetryCount: true)
        case .Cancelled:
          return
        }
      }
    }
  }

  func execute(task pTask: PersistentTask, delay: TimeInterval? = nil) {
    guard let executor = executors[pTask.task.type] else {
      fatalError("Trying to execute without registering an executor")
    }
    if delay != nil {
      changeManager?.willStart(task: pTask.task)
    } else {
      logger?.forgeInfo("Task \(pTask) passed on to executor")
      _execute(task: pTask, executor: executor)
    }
  }

  func undoChangeManagerAction(pTask: PersistentTask) {
    changeManager?.didComplete(task: pTask.task, result: Result.failure(ExecutorError.Cancelled))
    logger?.forgeInfo("Change manager reverts task \(pTask)")
  }

  /// Just like @p execute, but doesn't assert on executor's presence.
  func safeExecute(task pTask: PersistentTask) {
    guard let executor = executors[pTask.task.type] else {
      return
    }
    _execute(task: pTask, executor: executor)
  }

  var executors = [String: Executor]()
  func register(executor: Executor, for type: String) throws {
    if executors[type] != nil {
      throw ForgeError.typeRegisteredAlready
    }
    executors[type] = executor
  }

  /// To be made public only on requirement since this would impact executing tasks,
  /// retrial logic and tasks persistence.
  func deregister(executor: Executor, for type: String) throws {
    if executors[type] == nil {
      throw ForgeError.typeNotFound
    }
    executors.removeValue(forKey: type)
  }
}
