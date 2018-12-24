
import Result

public protocol Executor {

  func execute(task: Task, completion: (Result<Bool, ExecutorError>) -> Void)

}

class ExecutorManager {

  weak var changeManager: ChangeManager?
  func execute(task pTask: PersistentTask) {
    if let executor = executors[pTask.task.id] {
      changeManager?.willStart(task: pTask.task)
      executor.execute(task: pTask.task) { result in
        switch result {
        case .success(_):
          changeManager?.didComplete(task: pTask.task, result: result)
        case .failure(let error):
          switch error {
          case .NonRetriable:
            // remove task from persistor
            changeManager?.didComplete(task: pTask.task, result: result)
          case .ConditionalRetriable:
            // set as failed task
            // retry later
            return
          case .NonConditionalRetriable:
            // set as failed task
            // increase tried number
            // retry later if required, or fail here
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
