
import Foundation
import Result

protocol ExecutionDelegate: class {
  func delete(task: PersistentTask)
  func fail(task: PersistentTask, increaseRetryCount: Bool)
}

class ExecutionManager {

  weak var executionDelegate: ExecutionDelegate?
  weak var changeManager: ChangeManager?

  func execute(task pTask: PersistentTask) {
    if let executor = executors[pTask.task.id] {
      changeManager?.willStart(task: pTask.task)
      executor.execute(task: pTask.task) { result in
        switch result {
        case .success(_):
          executionDelegate?.delete(task: pTask)
          changeManager?.didComplete(task: pTask.task, result: result)
        case .failure(let error):
          switch error {
          case .NonRetriable:
            executionDelegate?.delete(task: pTask)
            changeManager?.didComplete(task: pTask.task, result: result)
          case .ConditionalRetriable:
            executionDelegate?.fail(task: pTask, increaseRetryCount: false)
            // set as failed task
            // retry later
            return
          case .NonConditionalRetriable:
            executionDelegate?.fail(task: pTask, increaseRetryCount: true)
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
