
import Foundation
import Result

protocol ExecutionDelegate: class {
  func start(pTask: PersistentTask)
  func delete(pTask: PersistentTask)
  func fail(pTask: PersistentTask, increaseRetryCount: Bool)
}

class ExecutionManager {

  weak var executionDelegate: ExecutionDelegate?
  weak var changeManager: ChangeManager?

  func execute(task pTask: PersistentTask) {
    if let executor = executors[pTask.task.id] {
      changeManager?.willStart(task: pTask.task)
      executionDelegate?.start(pTask: pTask)
      executor.execute(task: pTask.task) { result in
        switch result {
        case .success(_):
          executionDelegate?.delete(pTask: pTask)
          changeManager?.didComplete(task: pTask.task, result: result)
        case .failure(let error):
          switch error {
          case .NonRetriable:
            executionDelegate?.delete(pTask: pTask)
            changeManager?.didComplete(task: pTask.task, result: result)
          case .ConditionalRetriable:
            executionDelegate?.fail(pTask: pTask, increaseRetryCount: false)
            return
          case .NonConditionalRetriable:
            executionDelegate?.fail(pTask: pTask, increaseRetryCount: true)
            changeManager?.didComplete(task: pTask.task, result: result) // Possible in only certain cases
          }
        }
      }
    }
  }

  var executors = [String: Executor]()
  func register(executor: Executor, for type: String) {
    executors[type] = executor
  }
}
