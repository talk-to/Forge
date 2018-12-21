
public protocol Executor: ExecutorCallbacks {

  func execute(task: Task)

}

public protocol ExecutorCallbacks {

}
