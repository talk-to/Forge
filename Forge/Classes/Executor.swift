
import Result

public protocol Executor {

  func execute(task: Task, countOfRetries: Int, completion: (Result<Bool, ExecutorError>) -> Void)

}
