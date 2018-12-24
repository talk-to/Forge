
import Result

public protocol ChangeManager: class {

  func willStart(task: Task)

  func didComplete(task: Task, result: Result<Bool, ExecutorError>)
}
