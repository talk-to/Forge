
import Result

public protocol Executor {

  func execute(task: Task, countOfRetries: Int, completion: @escaping (Result<Bool, ExecutorError>) -> Void)

}
