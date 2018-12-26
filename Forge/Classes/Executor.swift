
import Result

public protocol Executor {

  func execute(task: Task, completion: (Result<Bool, ExecutorError>) -> Void)

}
