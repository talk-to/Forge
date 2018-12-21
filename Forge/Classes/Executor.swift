
import Result

public protocol Executor: ExecutorCallbacks {

  func execute(task: Task)

}

public protocol ExecutorCallbacks {

  func didComplete(task: Task, with: Result<Bool, ExecutorError>)

}
