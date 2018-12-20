
class TaskManager {

  public weak var changeManager: ChangeManager?

  public func submit(task: Task) {

  }

  public func register(executor: Executor, for type: IDType) {

  }
}

extension TaskManager: ExecutorCallbacks {

}
