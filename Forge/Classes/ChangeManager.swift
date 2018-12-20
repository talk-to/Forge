
import Result

public protocol ChangeManager: class {

  func willStart(task: Task)
  func didStart(task: Task)

  /// Should return @p YES if the task should be retried
  func didComplete(task: Task, result: Result<Bool, ExecutorError>) -> Bool
}
