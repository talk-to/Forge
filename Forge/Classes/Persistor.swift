
class Persistor {
  func save(task: PersistentTask) {

  }

  func completedTasks() -> [PersistentTask] {
    return []
  }

  func failedTasks() -> [PersistentTask] {
    return []
  }

  func tasks(ofType type: String) -> [PersistentTask] {
    return []
  }

  let UUID: String
  init(UUID: String) {
    self.UUID = UUID
  }
}

extension Persistor: ExecutionDelegate {
  func delete(task: PersistentTask) {

  }

  func fail(task: PersistentTask, increaseRetryCount: Bool) {

  }
}
